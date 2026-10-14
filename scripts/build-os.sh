#!/bin/bash
# build-os.sh - Build NEXUS OS from source

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           NEXUS OS - Network-Native Operating System       ║"
echo "║                    Build Script v1.0                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
BUILD_DIR="$(pwd)/build"
OUTPUT_DIR="$(pwd)/output"
KERNEL_VERSION="6.6.0"
BUSYBOX_VERSION="1.36.1"
ALPINE_VERSION="3.19"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_deps() {
    log_info "Checking build dependencies..."

    local deps=("gcc" "make" "wget" "squashfs-tools" "xorriso" "mtools")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Install with: sudo apt-get install ${missing[*]}"
        exit 1
    fi

    log_info "All dependencies satisfied"
}

# Download and build kernel
build_kernel() {
    log_info "Building Linux kernel ${KERNEL_VERSION}..."

    mkdir -p "$BUILD_DIR/kernel"
    cd "$BUILD_DIR/kernel"

    if [ ! -f "linux-${KERNEL_VERSION}.tar.xz" ]; then
        wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
    fi

    tar -xf "linux-${KERNEL_VERSION}.tar.xz"
    cd "linux-${KERNEL_VERSION}"

    # Apply NEXUS kernel patches
    if [ -f "../../../kernel/nexus-kernel.patch" ]; then
        log_info "Applying NEXUS kernel patches..."
        patch -p1 < ../../../kernel/nexus-kernel.patch || true
    fi

    # Minimal kernel config for network-native OS
    make defconfig

    # Enable required features
    cat >> .config << 'EOF'
CONFIG_FUSE_FS=y
CONFIG_CRYPTO_LIB_SODIUM=y
CONFIG_WASM=y
CONFIG_WAYLAND=y
CONFIG_QUIC=y
CONFIG_HTTP3=y
EOF

    make -j$(nproc)

    cp arch/x86/boot/bzImage "$OUTPUT_DIR/boot/vmlinuz"
    log_info "Kernel built: $OUTPUT_DIR/boot/vmlinuz"

    cd - > /dev/null
}

# Build initramfs
build_initramfs() {
    log_info "Building initramfs..."

    mkdir -p "$BUILD_DIR/initramfs"
    cd "$BUILD_DIR/initramfs"

    # Create directory structure
    mkdir -p {bin,sbin,etc,proc,sys,dev,run,tmp,var,usr/{bin,sbin,lib},mnt,nexus}

    # Copy BusyBox
    if [ ! -f "busybox-${BUSYBOX_VERSION}.tar.bz2" ]; then
        wget "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
    fi

    tar -xf "busybox-${BUSYBOX_VERSION}.tar.bz2"
    cd "busybox-${BUSYBOX_VERSION}"
    make defconfig
    make -j$(nproc)
    make CONFIG_PREFIX="$BUILD_DIR/initramfs" install
    cd - > /dev/null

    # Create init script
    cat > init << 'INITEOF'
#!/bin/sh
# NEXUS OS Init

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mount -t tmpfs none /run

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              NEXUS OS - Network-Native OS                  ║"
echo "║                   Booting...                               ║"
echo "╚════════════════════════════════════════════════════════════╝"

# Initialize identity
echo "[INIT] Initializing cryptographic identity..."
mkdir -p /etc/nexus
if [ ! -f /etc/nexus/identity.key ]; then
    dd if=/dev/urandom of=/etc/nexus/identity.key bs=32 count=1
    chmod 600 /etc/nexus/identity.key
    echo "[INIT] New identity generated"
else
    echo "[INIT] Identity loaded"
fi

# Mount network filesystem
echo "[INIT] Mounting network filesystem..."
mkdir -p /mnt/nexus-root
mount -t fuse.nexus none /mnt/nexus-root 2>/dev/null || echo "[INIT] Network FS: OFFLINE MODE"

# Start agent daemon
echo "[INIT] Starting agent daemon..."
/usr/bin/nexus-agentd &

# Start desktop
echo "[INIT] Starting network desktop..."
exec /usr/bin/nexus-desktop
INITEOF

    chmod +x init

    # Create initramfs image
    find . | cpio -H newc -o | gzip > "$OUTPUT_DIR/boot/initrd.img"

    log_info "Initramfs built: $OUTPUT_DIR/boot/initrd.img"
    cd - > /dev/null
}

# Build core services
build_services() {
    log_info "Building NEXUS core services..."

    mkdir -p "$BUILD_DIR/services"

    # Compile identity service
    gcc -O2 -o "$BUILD_DIR/services/nexus-identityd"         core/identity/nexus-id.c -lsodium

    # Compile network FS
    gcc -O2 -o "$BUILD_DIR/services/nexus-networkfs"         core/network-fs/nexus-fs.c -lsodium -lcurl -lfuse

    # Compile WASM runtime
    gcc -O2 -o "$BUILD_DIR/services/nexus-wasmrt"         core/runtime/wasm-sandbox.c -lwasmtime -lsodium

    # Compile agent daemon
    gcc -O2 -o "$BUILD_DIR/services/nexus-agentd"         core/agents/agent-daemon.c -lpthread -lcurl -ljson-c

    # Compile desktop
    gcc -O2 -o "$BUILD_DIR/services/nexus-desktop"         core/ui/network-desktop.c -lwayland-server -lcairo

    log_info "Core services built"
}

# Create bootable ISO
create_iso() {
    log_info "Creating bootable ISO..."

    mkdir -p "$OUTPUT_DIR/iso/boot/grub"

    # GRUB configuration
    cat > "$OUTPUT_DIR/iso/boot/grub/grub.cfg" << 'EOF'
set timeout=5
set default=0

menuentry "NEXUS OS - Network-Native OS" {
    linux /boot/vmlinuz quiet
    initrd /boot/initrd.img
}

menuentry "NEXUS OS - Recovery Mode" {
    linux /boot/vmlinuz single
    initrd /boot/initrd.img
}
EOF

    # Create ISO
    grub-mkrescue -o "$OUTPUT_DIR/nexus-os.iso" "$OUTPUT_DIR/iso" 2>/dev/null ||     xorriso -as mkisofs         -iso-level 3         -full-iso9660-filenames         -volid "NEXUS_OS"         -eltorito-boot boot/grub/bios.img         -no-emul-boot         -boot-load-size 4         -boot-info-table         -output "$OUTPUT_DIR/nexus-os.iso"         "$OUTPUT_DIR/iso"

    log_info "ISO created: $OUTPUT_DIR/nexus-os.iso"
}

# Main build
main() {
    mkdir -p "$BUILD_DIR" "$OUTPUT_DIR/boot"

    check_deps
    build_kernel
    build_initramfs
    build_services
    create_iso

    echo ""
    log_info "╔════════════════════════════════════════════════════════════╗"
    log_info "║              NEXUS OS Build Complete!                      ║"
    log_info "╚════════════════════════════════════════════════════════════╝"
    log_info "ISO: $OUTPUT_DIR/nexus-os.iso"
    log_info "Boot: $OUTPUT_DIR/boot/"
    log_info ""
    log_info "To install to USB:"
    log_info "  sudo dd if=$OUTPUT_DIR/nexus-os.iso of=/dev/sdX bs=4M"
    log_info ""
    log_info "To test in VM:"
    log_info "  qemu-system-x86_64 -cdrom $OUTPUT_DIR/nexus-os.iso -m 4G"
}

main "$@"
