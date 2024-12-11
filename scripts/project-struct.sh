#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

# Base project directory
PROJECT_DIR="luna"

# Create main project directory
print_status "Creating project directory at ${PROJECT_DIR}..."
sudo mkdir -p ${PROJECT_DIR}

# Create all directories
print_status "Creating directory structure..."
directories=(
    "config"
    "src"
    "src/audio"
    "src/vision"
    "src/ui"
    "src/ui/assets"
    "src/ui/templates"
    "src/utils"
    "tests"
)

for dir in "${directories[@]}"; do
    mkdir -p "${PROJECT_DIR}/${dir}"
    print_status "Created ${dir}/"
done

# Create initial files
print_status "Creating initial files..."

# Create __init__.py files
find "${PROJECT_DIR}" -type d -exec touch "{}/__init__.py" \;

# Create .env.example
cat > "${PROJECT_DIR}/.env.example" << EOL
# Picovoice Access Key
PICOVOICE_ACCESS_KEY=your_picovoice_key_here

# LiveKit Access Keys
LIVEKIT_API_KEY=your_livekit_api_key_here
LIVEKIT_API_SECRET=your_livekit_secret_here
EOL

# Create empty requirements.txt
touch "${PROJECT_DIR}/requirements.txt"

# Create basic config files
cat > "${PROJECT_DIR}/config/settings.py" << EOL
"""Global settings for the Luna Assistant."""

# Display settings
DISPLAY_WIDTH = 720
DISPLAY_HEIGHT = 1560

# Audio settings
SAMPLE_RATE = 16000
CHANNELS = 2
CHUNK_SIZE = 1024

# Vision settings
CAMERA_WIDTH = 640
CAMERA_HEIGHT = 480
CAMERA_FPS = 30
EOL

cat > "${PROJECT_DIR}/config/constants.py" << EOL
"""Constants used throughout the Luna Assistant."""

# Wake word settings
WAKE_WORD = "hi luna"
SLEEP_WORD = "goodnight luna"

# Path configurations
ASSETS_DIR = "src/ui/assets"
TEMPLATES_DIR = "src/ui/templates"

# Serial configurations
SERIAL_BAUDRATE = 115200
SERIAL_TIMEOUT = 1.0
EOL

# Set permissions
print_status "Setting permissions..."
sudo chown -R pi:pi ${PROJECT_DIR}
sudo chmod -R 755 ${PROJECT_DIR}

print_status "Project structure created successfully!"
print_status "Next steps:"
echo "1. Update requirements.txt with project dependencies"
echo "2. Copy .env.example to .env and add your API keys"
echo "3. Run setup.sh to install dependencies and configure the system"
