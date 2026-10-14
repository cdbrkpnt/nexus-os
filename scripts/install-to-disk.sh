#!/bin/bash
# install-to-disk.sh - Install NEXUS OS to disk

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           NEXUS OS - Disk Installation                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

# Detect target disk
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -E "sd|nvme|hd"
echo ""
read -p "Enter target disk (e.g., sda, nvme0n1): " TARGET_DISK

if [ ! -b "/dev/$TARGET_DISK" ]; then
    echo "Error: /dev/$TARGET_DISK not found"
    exit 1
fi

echo ""
echo "WARNING: This will ERASE ALL DATA on /dev/$TARGET_DISK"
read -p "Type 'YES' to confirm: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Installing NEXUS OS to /dev/$TARGET_DISK..."

# Partition
echo "[1/6] Creating partitions..."
parted -s "/dev/$TARGET_DISK" mklabel gpt
parted -s "/dev/$TARGET_DISK" mkpart primary fat32 1MiB 512MiB
parted -s "/dev/$TARGET_DISK" set 1 esp on
parted -s "/dev/$TARGET_DISK" mkpart primary ext4 512MiB 100%

# Format
echo "[2/6] Formatting partitions..."
mkfs.fat -F32 "/dev/${TARGET_DISK}1"
mkfs.ext4 -L nexus-root "/dev/${TARGET_DISK}2"

# Mount
echo "[3/6] Mounting..."
mount "/dev/${TARGET_DISK}2" /mnt
mkdir -p /mnt/boot/efi
mount "/dev/${TARGET_DISK}1" /mnt/boot/efi

# Copy system
echo "[4/6] Copying NEXUS OS..."
cp -r output/boot/* /mnt/boot/
cp -r core /mnt/
cp -r apps /mnt/
cp -r system /mnt/
cp -r config /mnt/

# Install bootloader
echo "[5/6] Installing bootloader..."
grub-install --target=x86_64-efi --efi-directory=/mnt/boot/efi --boot-directory=/mnt/boot "/dev/$TARGET_DISK"

# Create fstab
echo "[6/6] Configuring system..."
cat > /mnt/etc/fstab << EOF
/dev/${TARGET_DISK}2  /          ext4  defaults,noatime  0 1
/dev/${TARGET_DISK}1  /boot/efi  vfat  defaults          0 2
tmpfs                 /tmp       tmpfs defaults,noatime  0 0
EOF

# Unmount
umount -R /mnt

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           NEXUS OS Installation Complete!                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Remove installation media and reboot."
echo ""
echo "First boot:"
echo "  1. Cryptographic identity will be generated"
echo "  2. Network filesystem will initialize"
echo "  3. Agent daemon will start"
echo "  4. Network desktop will load"
echo ""
echo "Default login: nexus (no password - identity-based)"
