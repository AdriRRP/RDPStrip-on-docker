# RDPStrip-on-docker

**RDPStrip-Docker** is a Dockerized version of **RDPStrip**, a tool for performing man-in-the-middle (MiTM) attacks on Remote Desktop Protocol (RDP) connections. This project simplifies the setup and execution of RDPStrip in a containerized environment, making it easier to conduct security assessments and penetration testing.

This Docker setup automates the installation of dependencies and ensures RDPStrip runs smoothly without manual configuration.

## Features

- Automates ARP spoofing and port redirection for RDP MiTM.
- Captures cleartext credentials and logs keystrokes during RDP sessions.
- Saves captured RDP data to PCAP files for further analysis.
- Supports sniff-only mode for monitoring RDP traffic without active interception.

## Prerequisites

To build and run this Docker image, you need the following installed on your system:

- **Docker**: Installation instructions can be found on the [official Docker website](https://docs.docker.com/get-docker/).
- **Python 2.7**: This is included in the Docker image.

## How to Build and Run

### 1. Clone the repository

```bash
git clone https://github.com/your-username/RDPStrip-Docker.git
cd RDPStrip-Docker
```

### 2. Build the Docker image

Run the following command to build the Docker image. This will create a Docker image named `rdpstrip-docker` based on the provided `Dockerfile`:

```bash
docker build -t rdpstrip-docker .
```

### 3. Run the RDPStrip script using the provided shell script

The provided `rdpstrip.sh` script simplifies running the Docker container with the appropriate parameters. Below is an example command to launch RDPStrip in MiTM mode:

```bash
sudo ./rdpstrip.sh -m 10.0.0.3 -f 10.0.0.11:3389 -i eth0 -p 13389 -o customlog -c mycert -s
```

- `-m`: Client IP for ARP spoofing (MiTM mode).
- `-f`: Forwarding target in `IP:Port` format.
- `-i`: Network interface to use (e.g., `eth0`).
- `-p`: Listening port (default is `3389`).
- `-o`: Log file name (default is `rdpstriplog`).
- `-c`: Certificate file prefix (default is `cert`).
- `-s`: Sniff-only mode.

### 4. Post-run cleanup

After running the container, the `rdpstrip.sh` script will:

- Disable IP forwarding.
- Restore the original `iptables` configuration.

## Notes

- Ensure you have sufficient privileges to run Docker and modify `iptables` rules.
- For security reasons, always restore your original network configuration after testing.

## Disclaimer

**RDPStrip-Docker** is intended for authorized security testing and research purposes only. Unauthorized use of this tool may violate local, state, or federal laws. Use responsibly and ensure you have permission before conducting any tests.

## Reference

This project is based on the original [RDPStrip script](https://github.com/tijldeneut/Security) by [Tijl Deneut](https://github.com/tijldeneut).

