# Use an official Python 2 base image
FROM python:2.7-slim

# Set the working directory in the container
WORKDIR /app

# Install required system dependencies and build tools
RUN apt-get update && apt-get install -y \
    libpcap0.8-dev \
    libssl-dev \
    libffi-dev \
    iptables \
    build-essential \
    gcc \
    python-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest compatible version for Python 2.7
RUN pip install --upgrade pip==20.3.4

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Download the specific script from the repository
ADD https://raw.githubusercontent.com/tijldeneut/Security/master/rdpstrip.py /app/rdpstrip.py

# Ensure the script is executable
RUN chmod +x /app/rdpstrip.py

# Define the entrypoint for the container
ENTRYPOINT ["python", "/app/rdpstrip.py"]
