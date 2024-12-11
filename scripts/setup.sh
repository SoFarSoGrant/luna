#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root"
    exit 1
fi

# Update and upgrade system
print_status "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install system dependencies
print_status "Installing system dependencies..."
apt-get install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    portaudio19-dev \
    libatlas-base-dev \
    git \
    cmake \
    build-essential \
    libopencv-dev \
    python3-opencv \
    libasound2-dev

# Create project directory
PROJECT_DIR="/opt/luna"
print_status "Setting up project directory at ${PROJECT_DIR}..."
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}

# Remove existing virtual environment if it exists
if [ -d "venv" ]; then
    print_status "Removing existing virtual environment..."
    rm -rf venv
fi

# Create and activate virtual environment
print_status "Creating new virtual environment..."
python3 -m venv venv --system-site-packages
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Clone or update repository
if [ -d ".git" ]; then
    print_status "Updating existing repository..."
    git pull origin main
else
    print_status "Cloning repository..."
    git clone https://github.com/SoFarSoGrant/luna .
fi

# Check for requirements.txt
if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found!"
    exit 1
fi

# Install Python dependencies
print_status "Installing Python dependencies..."
pip install -r requirements.txt

# Configure serial port
print_status "Configuring serial port..."
raspi-config nonint do_serial 2  # Disable serial login shell
raspi-config nonint set_config_var enable_uart 1 /boot/config.txt  # Enable UART

# Create .env file from template if it doesn't exist
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
fi

# Check for environment variables
check_env_var() {
    local var_name=$1
    local var_value
    
    if [ -f ".env" ]; then
        var_value=$(grep "^${var_name}=" .env | cut -d '=' -f2)
    fi
    
    if [ -z "${var_value}" ]; then
        print_warning "${var_name} not found in environment"
        read -p "Would you like to add ${var_name} now? [y/N]: " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            read -p "Enter ${var_name}: " new_value
            if [ -f ".env" ]; then
                sed -i "/^${var_name}=/d" .env
            fi
            echo "${var_name}=${new_value}" >> .env
        fi
    fi
}

print_status "Checking environment variables..."
check_env_var "PICOVOICE_ACCESS_KEY"
check_env_var "LIVEKIT_API_KEY"
check_env_var "LIVEKIT_API_SECRET"

# Set permissions
print_status "Setting permissions..."
chown -R pi:pi ${PROJECT_DIR}
chmod -R 755 ${PROJECT_DIR}

print_status "Setup complete. It is recommended to reboot the Raspberry Pi."
read -p "Do you want to reboot now? [y/N]: " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_status "Rebooting..."
    reboot
fi
