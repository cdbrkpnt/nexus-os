#!/bin/bash
# create-buildable.sh - Create actually buildable NEXUS OS prototype

set -e

echo "Creating buildable NEXUS OS prototype..."

# Method 1: Use Alpine Linux as base (fastest)
cat > Dockerfile.alpine << 'EOF'
FROM alpine:3.19

# Install base system
RUN apk add --no-cache     linux-lts     busybox     fuse3     libsodium     curl     wayland-server     cairo     json-c     build-base

# Create NEXUS directory structure
RUN mkdir -p /nexus/{core,apps,config,system}

# Copy NEXUS components
COPY core/ /nexus/core/
COPY apps/ /nexus/apps/
COPY config/ /nexus/config/
COPY system/ /nexus/system/

# Build NEXUS services
RUN cd /nexus/core/identity &&     gcc -O2 -o /usr/bin/nexus-identityd nexus-id.c -lsodium &&     cd /nexus/core/network-fs &&     gcc -O2 -o /usr/bin/nexus-networkfs nexus-fs.c -lsodium -lcurl -lfuse3 &&     cd /nexus/core/agents &&     gcc -O2 -o /usr/bin/nexus-agentd agent-daemon.c -lpthread -lcurl -ljson-c &&     cd /nexus/core/ui &&     gcc -O2 -o /usr/bin/nexus-desktop network-desktop.c -lwayland-server -lcairo

# Build apps
RUN cd /nexus/apps/terminal &&     gcc -O2 -o /usr/bin/nexus-term nexus-term.c &&     cd /nexus/apps/files &&     gcc -O2 -o /usr/bin/nexus-files nexus-files.c &&     cd /nexus/apps/browser-killer &&     gcc -O2 -o /usr/bin/nexus-net nexus-net.c -lcurl -ljson-c &&     cd /nexus/apps/game-stream &&     gcc -O2 -o /usr/bin/nexus-game nexus-game.c

# Create init script
RUN cat > /init << 'INIT'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              NEXUS OS - Network-Native OS                  ║"
echo "║                   Booting...                               ║"
echo "╚════════════════════════════════════════════════════════════╝"

# Initialize identity
echo "[INIT] Initializing cryptographic identity..."
mkdir -p /etc/nexus
if [ ! -f /etc/nexus/identity.key ]; then
    dd if=/dev/urandom of=/etc/nexus/identity.key bs=32 count=1 2>/dev/null
    chmod 600 /etc/nexus/identity.key
    echo "[INIT] New identity generated"
fi

# Start services
echo "[INIT] Starting NEXUS services..."
/usr/bin/nexus-identityd &
/usr/bin/nexus-agentd &

# Start desktop or shell
echo "[INIT] Starting desktop..."
if [ -n "$DISPLAY" ] || [ -e /dev/dri/card0 ]; then
    exec /usr/bin/nexus-desktop
else
    echo "[INIT] No GPU detected, starting terminal..."
    exec /bin/sh
fi
INIT
chmod +x /init

CMD ["/init"]
EOF

# Method 2: Buildroot external tree (proper embedded build)
mkdir -p buildroot-external
cat > buildroot-external/external.mk << 'EOF'
# NEXUS OS Buildroot external tree

NEXUS_VERSION = 1.0.0
NEXUS_SITE = $(BR2_EXTERNAL_NEXUS_PATH)/../core
NEXUS_LICENSE = MIT

define NEXUS_BUILD_CMDS
    $(TARGET_CC) $(TARGET_CFLAGS) -O2 -o $(@D)/nexus-identityd         $(BR2_EXTERNAL_NEXUS_PATH)/../core/identity/nexus-id.c -lsodium
    $(TARGET_CC) $(TARGET_CFLAGS) -O2 -o $(@D)/nexus-networkfs         $(BR2_EXTERNAL_NEXUS_PATH)/../core/network-fs/nexus-fs.c -lsodium -lcurl -lfuse3
endef

define NEXUS_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/nexus-identityd $(TARGET_DIR)/usr/bin/nexus-identityd
    $(INSTALL) -D -m 0755 $(@D)/nexus-networkfs $(TARGET_DIR)/usr/bin/nexus-networkfs
endef

$(eval $(generic-package))
EOF

cat > buildroot-external/Config.in << 'EOF'
config BR2_PACKAGE_NEXUS
    bool "nexus-os"
    help
      NEXUS OS - Network-native operating system core services.

      Includes:
      - Cryptographic identity layer
      - Content-addressed network filesystem
      - WASM app runtime
      - Background agent daemon
      - Wayland network desktop
EOF

cat > buildroot-external/external.desc << 'EOF'
name: NEXUS
desc: NEXUS OS - Network-native operating system
EOF

# Method 3: Quick QEMU test script
cat > test-qemu.sh << 'EOF'
#!/bin/bash
# Test NEXUS OS in QEMU

echo "Starting NEXUS OS in QEMU..."

qemu-system-x86_64     -kernel output/boot/vmlinuz     -initrd output/boot/initrd.img     -append "console=ttyS0 nexus.live=1"     -m 4G     -cpu host     -enable-kvm     -nographic     -netdev user,id=net0     -device virtio-net-pci,netdev=net0

echo "QEMU exited."
EOF
chmod +x test-qemu.sh

echo "✅ Buildable prototype created"
echo ""
echo "Build methods:"
echo "  1. Docker:     docker build -f Dockerfile.alpine -t nexus-os ."
echo "  2. Buildroot:  make BR2_EXTERNAL=buildroot-external nexus_defconfig && make"
echo "  3. QEMU test:  ./test-qemu.sh"
