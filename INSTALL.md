# NEXUS OS - Complete Installation Guide

## Overview

NEXUS OS is a **network-native operating system** — the internet is the filesystem, runtime, and distribution layer. This guide covers all installation methods.

---

## System Requirements

### Minimum
- **CPU**: x86_64 with virtualization (Intel VT-x / AMD-V)
- **RAM**: 4 GB
- **Storage**: 20 GB
- **Network**: Ethernet or WiFi adapter
- **GPU**: Any with Wayland support (Intel/AMD/NVIDIA)

### Recommended
- **CPU**: 4+ cores
- **RAM**: 16 GB
- **Storage**: 100 GB NVMe
- **Network**: 100+ Mbps (fiber/5G)
- **GPU**: Vulkan-capable for gaming features

---

## Installation Methods

### Method 1: Live USB (Try First)

**Step 1: Download**
```bash
wget https://nexus-os.org/releases/nexus-os-1.0.0.iso
# Verify: sha256sum nexus-os-1.0.0.iso
```

**Step 2: Create USB**
```bash
# Linux
sudo dd if=nexus-os-1.0.0.iso of=/dev/sdX bs=4M status=progress
sync

# macOS
sudo dd if=nexus-os-1.0.0.iso of=/dev/diskX bs=4m
sync

# Windows: Use Rufus or Etcher
```

**Step 3: Boot**
1. Insert USB
2. Reboot, enter boot menu (F12/F2/Del)
3. Select USB drive
4. Choose "NEXUS OS - Live"

**Step 4: Try**
- Desktop loads with live tiles
- Terminal: `nexus-term`
- Files: `nexus-files`
- Internet: `nexus-net fetch https://example.com`

---

### Method 2: Install to Disk

**From Live USB:**

```bash
# Launch installer
sudo nexus-install

# Or manual installation:
sudo ./scripts/install-to-disk.sh
```

**Manual Partitioning:**

```bash
# Create partitions
parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart primary fat32 1MiB 512MiB
parted -s /dev/nvme0n1 set 1 esp on
parted -s /dev/nvme0n1 mkpart primary ext4 512MiB 100%

# Format
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 -L nexus-root /dev/nvme0n1p2

# Mount
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

# Copy system
cp -r /nexus/* /mnt/

# Install bootloader
grub-install --target=x86_64-efi     --efi-directory=/mnt/boot/efi     --boot-directory=/mnt/boot     /dev/nvme0n1

# Configure
cat > /mnt/etc/fstab << EOF
/dev/nvme0n1p2  /          ext4  defaults,noatime  0 1
/dev/nvme0n1p1  /boot/efi  vfat  defaults          0 2
tmpfs           /tmp       tmpfs defaults,noatime  0 0
EOF

umount -R /mnt
reboot
```

---

### Method 3: Virtual Machine

**QEMU/KVM:**
```bash
qemu-system-x86_64     -cdrom nexus-os.iso     -m 8G     -cpu host     -enable-kvm     -smp 4     -vga virtio     -usb -device usb-tablet     -netdev user,id=net0     -device virtio-net-pci,netdev=net0     -drive file=nexus-disk.img,if=virtio,size=30G
```

**VirtualBox:**
1. New VM → Linux 6.x 64-bit
2. RAM: 8192 MB
3. Disk: 30 GB VDI
4. Settings → System → Enable EFI
5. Settings → Display → VMSVGA, 128MB
6. Attach ISO, boot

**VMware:**
1. Create VM → Other Linux 5.x kernel 64-bit
2. RAM: 8192 MB
3. Disk: 30 GB
4. Boot with ISO

---

### Method 4: Build from Source

**Prerequisites:**
```bash
# Debian/Ubuntu
sudo apt-get install build-essential wget squashfs-tools xorriso mtools     libfuse3-dev libsodium-dev libcurl4-openssl-dev libjson-c-dev     libwayland-dev libcairo2-dev qemu-utils

# Fedora
sudo dnf install gcc make wget squashfs-tools xorriso mtools     fuse3-devel libsodium-devel libcurl-devel json-c-devel     wayland-devel cairo-devel qemu-img
```

**Build:**
```bash
git clone https://github.com/nexus-os/nexus.git
cd nexus

# Full build (kernel + initramfs + ISO)
./scripts/build-os.sh

# Output: output/nexus-os.iso
```

**Build Individual Components:**
```bash
# Identity service
gcc -O2 -o nexus-identityd core/identity/nexus-id.c -lsodium

# Network filesystem
gcc -O2 -o nexus-networkfs core/network-fs/nexus-fs.c -lsodium -lcurl -lfuse3

# Agent daemon
gcc -O2 -o nexus-agentd core/agents/agent-daemon.c -lpthread -lcurl -ljson-c

# Desktop
gcc -O2 -o nexus-desktop core/ui/network-desktop.c -lwayland-server -lcairo
```

---

### Method 5: Docker (Development)

```bash
# Build container
docker build -f Dockerfile.alpine -t nexus-os .

# Run
docker run -it --rm     --device /dev/fuse     --cap-add SYS_ADMIN     nexus-os

# With GPU
docker run -it --rm     --device /dev/fuse     --device /dev/dri     --cap-add SYS_ADMIN     -e DISPLAY=$DISPLAY     -v /tmp/.X11-unix:/tmp/.X11-unix     nexus-os
```

---

### Method 6: Buildroot (Embedded)

```bash
# Get Buildroot
wget https://buildroot.org/downloads/buildroot-2024.02.tar.gz
tar -xf buildroot-2024.02.tar.gz
cd buildroot-2024.02

# Configure with NEXUS external tree
make BR2_EXTERNAL=/path/to/nexus/buildroot-external nexus_defconfig

# Build
make -j$(nproc)

# Output: output/images/nexus-os.img
```

---

## Post-Installation

### First Boot

1. **Identity Setup**
   ```
   ┌─────────────────────────────────────────┐
   │  NEXUS OS - Identity Setup              │
   ├─────────────────────────────────────────┤
   │                                         │
   │  ☐ Generate new identity                │
   │  ☐ Restore from backup                  │
   │  ☐ Import from existing key             │
   │                                         │
   │  Home Pod: [auto-detect        ]        │
   │                                         │
   │  [Continue]  [Advanced]                 │
   │                                         │
   └─────────────────────────────────────────┘
   ```

2. **Network Configuration**
   - Ethernet: automatic (DHCP)
   - WiFi: `nexus-wifi connect SSID password`
   - Static: edit `/etc/nexus/network.conf`

3. **Home Pod Setup**
   - Default: NEXUS-hosted pod (free tier: 10GB)
   - Self-host: `nexus-pod init --storage /mnt/pod`
   - Custom: `nexus-pod connect pod.example.com`

### Desktop Tour

```
┌─────────────────────────────────────────────────────────────┐
│  NEXUS    Network: ● Connected    Latency: 12ms    did:nexus:7a3f...  │
├──────────┬──────────────────────────────────────┬───────────┤
│ LIVE     │                                      │ PRESENCE  │
│ TILES    │         Active Apps                  │           │
│          │                                      │ ● You     │
│ NIFTY    │  ┌────────┐ ┌────────┐ ┌────────┐  │ ● Alice   │
│ 19,450   │  │Terminal│ │ Files  │ │ Game   │  │   (doc1)  │
│ +1.2%    │  │        │ │        │ │        │  │           │
│          │  └────────┘ └────────┘ └────────┘  │ ● Bob     │
│ BTC      │                                      │   (game)  │
│ $67,230  │  ┌────────┐ ┌────────┐ ┌────────┐  │           │
│ +2.1%    │  │ Browser│ │ Agent  │ │ Settings│  │           │
│          │  │ Killer │ │ Monitor│ │        │  │           │
│ Agents   │  │        │ │        │ │        │  │           │
│ ● 2 live │  └────────┘ └────────┘ └────────┘  │           │
│          │                                      │           │
├──────────┴──────────────────────────────────────┴───────────┤
│  Status: Synced 2s ago    Cache: 3.2/10 GB    Agents: 2     │
└─────────────────────────────────────────────────────────────┘
```

### Essential Commands

```bash
# Identity
nexus-id show              # Show your DID
nexus-id backup            # Backup identity key
nexus-id restore <file>    # Restore identity

# Filesystem
nexus-fs status            # Show sync status
nexus-fs pin <hash>        # Pin object locally
nexus-fs share <hash>      # Create share link

# Apps
nexus-app list             # List running apps
nexus-app launch <url>     # Launch network app
nexus-app kill <id>        # Terminate app

# Agents
nexus-agent list           # List agents
nexus-agent spawn <type>   # Spawn new agent
nexus-agent logs <id>      # View agent logs

# Network
nexus-net fetch <url>      # Fetch as structured data
nexus-net app <nexus://>   # Launch network app

# Gaming
nexus-game list            # List games
nexus-game play <id>       # Play game
nexus-game spectate <id>   # Spectate as ghost
```

---

## Troubleshooting

### Boot Issues

**"No bootable device"**
- Check: BIOS/UEFI boot mode matches installation (UEFI recommended)
- Fix: Re-create USB with Rufus (Windows) or dd (Linux)

**Black screen after boot**
- Try: `nomodeset` kernel parameter
- Check: GPU compatibility (Intel/AMD best)

### Network Issues

**No WiFi**
```bash
# Check adapter
lspci | grep -i network
lsusb | grep -i wireless

# Load driver
modprobe iwlwifi  # Intel
modprobe ath9k    # Atheros

# Connect
nexus-wifi scan
nexus-wifi connect SSID password
```

**Slow sync**
- Check latency: `ping pod.nexus.network`
- Reduce cache: edit `/etc/nexus/nexus.conf`
- Disable live tiles: `nexus-desktop --no-tiles`

### Identity Issues

**Lost identity key**
- Restore from backup: `nexus-id restore /mnt/backup/identity.key`
- No backup: Generate new (loses access to old data)

**Home pod unreachable**
```bash
# Check status
nexus-pod status

# Switch to local-only mode
nexus-pod mode offline

# Reconnect
nexus-pod connect backup-pod.example.com
```

---

## Advanced

### Self-Hosted Home Pod

```bash
# Install pod server
curl -sSL https://get.nexus-pod.org | sh

# Initialize
nexus-pod init     --storage /var/lib/nexus-pod     --domain pod.example.com     --tls certbot

# Start
systemctl start nexus-pod

# Connect OS to pod
nexus-pod connect pod.example.com
```

### Custom App Development

```c
// my-app.c - NEXUS network app
#include <nexus.h>

int main() {
    // Request capabilities
    nexus_cap_request("read:photos");
    nexus_cap_request("network:api.example.com");

    // Access network filesystem
    nexus_file_t *file = nexus_fs_open("bafybeihdwdcefgh...");

    // Spawn agent
    nexus_agent_t *agent = nexus_agent_spawn("my-monitor", script, 1);

    // Render UI
    nexus_window_t *win = nexus_window_create("My App", 800, 600);
    nexus_window_render(win, my_draw_callback);

    return 0;
}
```

Compile:
```bash
nexus-app-build my-app.c -o my-app.wasm
nexus-app sign my-app.wasm --key developer.key
nexus-app publish my-app.wasm --to nexus://apps/my-app
```

---

## Support

- **Docs**: https://nexus-os.org/docs
- **Community**: https://community.nexus-os.org
- **Issues**: https://github.com/nexus-os/nexus/issues
- **Chat**: #nexus-os on Libera.Chat

---

**Welcome to NEXUS OS — The internet is the computer.**
