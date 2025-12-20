set -e

# Get project name from script's parent directory
PROJECT_NAME="$(basename "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"

# Log file
LOG_FILE="/var/log/${PROJECT_NAME}-bootstrap.log"

# ANSI color codes
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m'

# Logging function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "☁️ cloud-init package install finished. starting bootstrap.sh..."
sleep 2

# Install NVIDIA drivers (skip if already installed)
if nvidia-smi > /dev/null 2>&1; then
    log "🎮 NVIDIA drivers already installed, skipping..."
else
    log "🎮 Installing NVIDIA drivers...(this may takes 2 - 3 minutes)"
    ubuntu-drivers autoinstall
fi

# Install Docker (skip if already installed)
if command -v docker > /dev/null 2>&1; then
    log "🐳 Docker already installed, skipping..."
else
    log "🐳 Installing Docker & Compose..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

DOCKER_RESTART_NEEDED=false
# Install NVIDIA Container Toolkit (skip if already installed)
if dpkg -l | grep -q nvidia-container-toolkit; then
    log "📦 NVIDIA Container Toolkit already installed, skipping..."
else
    log "📦 Installing NVIDIA Container Toolkit..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update
    apt-get install -y nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
    DOCKER_RESTART_NEEDED=true
fi

# Configure Docker registry mirrors
if [ ! -f /etc/docker/daemon.json ]; then
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": [
    "https://mirror.gcr.io"
  ]
}
EOF
    DOCKER_RESTART_NEEDED=true
fi

# Restart Docker if needed
if [ "$DOCKER_RESTART_NEEDED" = true ]; then
    log "🔄 Restarting Docker to apply changes..."
    systemctl restart docker
fi

# Download project files from GitHub
log "📥 Downloading project files from GitHub..."
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/linode/${PROJECT_NAME}/archive/refs/heads/main.zip" -o "${TEMP_DIR}/repo.zip"
unzip -q "${TEMP_DIR}/repo.zip" -d "${TEMP_DIR}"
cp -r "${TEMP_DIR}/${PROJECT_NAME}-main/setup/"* "/opt/${PROJECT_NAME}/"
rm -rf "${TEMP_DIR}"

# Create systemd service for AI Quickstart Stack
log "⚙️ Registering systemd service for ${PROJECT_NAME} stack ..."
cat > /etc/systemd/system/${PROJECT_NAME}.service << EOF
[Unit]
Description=Start ${PROJECT_NAME} Stack
After=docker.service
Requires=docker.service
[Service]
Type=oneshot
WorkingDirectory=/opt/${PROJECT_NAME}
ExecStart=/usr/bin/docker compose --progress quiet up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for setup.sh to run at boot
if [ -f "/opt/${PROJECT_NAME}/setup.sh" ]; then
    log "⚙️ Registering systemd service for ${PROJECT_NAME} setup ..."
    cat > /etc/systemd/system/${PROJECT_NAME}-setup.service << EOF
[Unit]
Description=Setup ${PROJECT_NAME} Stack at boot
After=${PROJECT_NAME}.service
Requires=${PROJECT_NAME}.service
[Service]
Type=oneshot
ExecStart=/bin/bash /opt/${PROJECT_NAME}/setup.sh
RemainAfterExit=no
[Install]
WantedBy=multi-user.target
EOF
fi

# Enable services (will start containers on boot)
systemctl daemon-reload
systemctl enable ${PROJECT_NAME}.service
[ -f "/opt/${PROJECT_NAME}/setup.sh" ] && systemctl enable ${PROJECT_NAME}-setup.service

# Create .env file with domain configuration
log "🌐 Configuring domain with public IP..."
IP_LABEL=$(curl -s https://ipinfo.io/ip | tr . -)
cat > /opt/${PROJECT_NAME}/.env << EOF
SUBDOMAIN=${IP_LABEL}
DOMAIN_NAME=ip.linodeusercontent.com
EOF

# Pull latest Docker images
log "⬇️ Downloading container images... (this may take 2 - 3 min)..."
cd /opt/${PROJECT_NAME}
docker compose pull --quiet || true

# Check if NVIDIA modules exist for current kernel
CURRENT_KERNEL=$(uname -r)
if [ -f "/lib/modules/${CURRENT_KERNEL}/kernel/nvidia-580-open/nvidia.ko" ] || \
   [ -f "/lib/modules/${CURRENT_KERNEL}/updates/dkms/nvidia.ko" ]; then
    # Modules exist, load them and start containers now
    log "🔧 Loading NVIDIA kernel modules..."
    modprobe nvidia 2>/dev/null || true
    modprobe nvidia-uvm 2>/dev/null || true
    modprobe nvidia-modeset 2>/dev/null || true

    # Verify driver is loaded
    if nvidia-smi > /dev/null 2>&1; then
        # Start AI Quickstart Stack
        cd /opt/${PROJECT_NAME}
        log "🚀 Starting docker compose up ..."
        docker compose up -d
        exit 0
    fi
fi

log "🔄 Rebooting to load NVIDIA drivers... 🚀 setup will continue after reboot"
reboot
