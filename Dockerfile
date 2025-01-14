# Use an official Python 2 base image
FROM python:2.7-slim

# Set the working directory in the container
WORKDIR /app

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libpcap0.8-dev \
    libssl-dev \
    iptables \
    scapy \
    && rm -rf /var/lib/apt/lists/*

# Download the specific script from the repository
ADD https://raw.githubusercontent.com/tijldeneut/Security/master/rdpstrip.py /app/rdpstrip.py

# Ensure the script is executable
RUN chmod +x /app/rdpstrip.py

# Expose the default RDP port
EXPOSE 3389

# Define the entrypoint for the container
ENTRYPOINT ["python", "/app/rdpstrip.py"]
