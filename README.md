# NEXUS OS - Network-Native Operating System

## Overview

NEXUS OS is a **network-native desktop operating system** where the internet is the filesystem, the runtime, and the distribution layer — not just a destination you visit.

**Core Philosophy:**
- **No browser.** The OS speaks HTTP/3, WebRTC, and gRPC natively. Every window is a first-class network citizen.
- **No installs.** Apps stream as signed WASM modules, run sandboxed, and evaporate.
- **No local saves.** State persists transactionally to your cryptographic identity's home pod.
- **No files.** Content-addressed objects with live sync, not static documents.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    NEXUS Desktop (Wayland)                   │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────────┐   │
│  │ Terminal│ │ Files   │ │ Browser │ │ Game Stream     │   │
│  │ (net)   │ │ (CAS)   │ │ Killer  │ │ (state sync)    │   │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────────┬────────┘   │
│       └─────────────┴─────────┴─────────────┘              │
│                         │                                    │
│  ┌──────────────────────┴──────────────────────────┐        │
│  │              WASM Sandbox Runtime                │        │
│  │  • Capability-based security                     │        │
│  │  • App streaming (no install)                    │        │
│  │  • Ephemeral execution                           │        │
│  └──────────────────────┬──────────────────────────┘        │
│                         │                                    │
│  ┌──────────────────────┴──────────────────────────┐        │
│  │            Agent Daemon (24/7 background)        │        │
│  │  • Market monitors                               │        │
│  │  • Game NPCs (persistent)                        │        │
│  │  • Notification routers                          │        │
│  └──────────────────────┬──────────────────────────┘        │
│                         │                                    │
│  ┌──────────────────────┴──────────────────────────┐        │
│  │         Network Filesystem (FUSE)                │        │
│  │  • Content-addressed storage (BLAKE3)            │        │
│  │  • LRU local cache (10GB default)                │        │
│  │  • Real-time sync (CRDT)                         │        │
│  └──────────────────────┬──────────────────────────┘        │
│                         │                                    │
│  ┌──────────────────────┴──────────────────────────┐        │
│  │         Cryptographic Identity Layer             │        │
│  │  • Keypair = root directory                      │        │
│  │  • DID: did:nexus:<public_key>                   │        │
│  │  • Home pod: personal cloud node                 │        │
│  └──────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   Network Layer    │
                    │  • QUIC/HTTP3      │
                    │  • WebRTC          │
                    │  • gRPC            │
                    └───────────────────┘
```

---

## Key Features

### 1. Cryptographic Identity
- Your keypair IS your filesystem root
- `did:nexus:z6Mkf...` identifies you across all machines
- Sit at any NEXUS machine, authenticate, your environment hydrates

### 2. Network-Native Filesystem
- Local disk = LRU cache (10GB default)
- Network = source of truth
- Content-addressed: automatic deduplication
- Real-time sync: no "Save" button, no version conflicts (CRDT)

### 3. WASM App Runtime
- Apps are URLs with capabilities, not installed software
- Signed WASM modules stream on-demand
- Capability-based security: `read:photos`, `write:docs`, `network:api.twitter`
- Ephemeral: apps evaporate when closed, leaving no trace

### 4. Persistent Agent Layer
- Background agents run 24/7 in your home pod
- Wake-on-intent: sleep until network event matches filters
- Examples: market monitors, game NPCs, news aggregators

### 5. Network Desktop
- Live tiles: real-time data (markets, presence, agents)
- Latency-adaptive UI: degrades gracefully on slow networks
- Presence-aware: see who's editing a document, like Google Docs but OS-wide

### 6. Gaming-Native
- Games as persistent network objects
- State sync, not video streaming (ghost spectating)
- Live mod subscriptions (no installation)
- Cross-device continuity (desktop → phone → VR)

---

## Installation

### Option 1: Live USB (Try Without Installing)

```bash
# Download ISO
wget https://nexus-os.org/releases/nexus-os-1.0.0.iso

# Write to USB (replace sdX with your USB drive)
sudo dd if=nexus-os-1.0.0.iso of=/dev/sdX bs=4M status=progress

# Boot from USB
```

### Option 2: Install to Disk

```bash
# Boot live USB, then:
sudo nexus-install

# Or manually:
sudo ./scripts/install-to-disk.sh
```

### Option 3: Virtual Machine

```bash
# QEMU
qemu-system-x86_64   -cdrom nexus-os.iso   -m 8G   -cpu host   -enable-kvm   -vga virtio   -usb -device usb-tablet

# VirtualBox
# Create VM: Linux 6.x 64-bit, 8GB RAM, 30GB disk
# Attach ISO, boot
```

### Option 4: Build from Source

```bash
# Dependencies (Debian/Ubuntu)
sudo apt-get install build-essential wget squashfs-tools xorriso mtools

# Build
./scripts/build-os.sh

# Output: output/nexus-os.iso
```

---

## First Boot

1. **Identity Generation**: Cryptographic keypair created automatically
2. **Home Pod Setup**: Connect to default pod or self-host
3. **Network FS Mount**: `/mnt/nexus-root` becomes your "home"
4. **Agent Activation**: Default agents start (market, news, presence)
5. **Desktop Load**: Wayland compositor with live tiles

---

## Usage

### Terminal

```bash
# All commands operate on network objects
nexus-terminal

nexus:~$ ls
Documents/    Photos/    Agents/    Games/
@market-data    @news-feed    @trading-bot

nexus:~$ agents
Active agents:
  agent-0-...  market-monitor    [WAKE-ON-INTENT]
  agent-1-...  game-npc          [ALWAYS-ON]

nexus:~$ spawn trading-bot --strategy momentum
```

### Files

```bash
nexus-files

# Browse content-addressed objects
# Open by hash, not path
# Pin important objects to local cache
```

### Internet (No Browser)

```bash
# Fetch web content as structured data
nexus-net fetch https://example.com/article

# Launch network app
nexus-net app nexus://photo-editor/bafybeihdwdcefgh...
```

### Gaming

```bash
nexus-game

# Play (streams assets, syncs state)
nexus-game play bafybeigame001...

# Spectate (ghost mode, ~1 KB/s)
nexus-game spectate bafybeigame001... player123
```

---

## Configuration

Edit `/etc/nexus/nexus.conf`:

```ini
[identity]
key_file = /etc/nexus/identity.key
home_pod = auto  # or: pod.example.com, disabled

[network]
quic_enabled = true
edge_cache_size_gb = 10

[filesystem]
chunk_size = 262144
deduplication = true
local_cache_gb = 10

[runtime]
sandbox = wasmtime
max_apps = 32

[agents]
max_agents = 32
wake_on_intent = true

[ui]
compositor = wayland
latency_adaptive = true
```

---

## Development

### Project Structure

```
nexus-os/
├── boot/                 # Bootloader configs
├── kernel/               # Linux kernel + NEXUS patches
├── core/
│   ├── identity/         # Cryptographic identity
│   ├── network-fs/       # Content-addressed filesystem
│   ├── runtime/          # WASM sandbox
│   ├── agents/           # Background agent daemon
│   └── ui/               # Wayland compositor
├── apps/                 # Native network apps
│   ├── terminal/
│   ├── files/
│   ├── browser-killer/
│   └── game-stream/
├── system/               # systemd services
├── config/               # OS configuration
└── scripts/              # Build & install
```

### Building Individual Components

```bash
# Identity service
gcc -O2 -o nexus-identityd core/identity/nexus-id.c -lsodium

# Network filesystem
gcc -O2 -o nexus-networkfs core/network-fs/nexus-fs.c -lsodium -lcurl -lfuse

# WASM runtime
gcc -O2 -o nexus-wasmrt core/runtime/wasm-sandbox.c -lwasmtime -lsodium

# Agent daemon
gcc -O2 -o nexus-agentd core/agents/agent-daemon.c -lpthread -lcurl -ljson-c

# Desktop
gcc -O2 -o nexus-desktop core/ui/network-desktop.c -lwayland-server -lcairo
```

---

## Roadmap

- [x] Cryptographic identity layer
- [x] Content-addressed filesystem
- [x] WASM sandbox runtime
- [x] Agent daemon
- [x] Network desktop compositor
- [ ] Home pod reference implementation
- [ ] App marketplace (capability-based)
- [ ] Game state sync protocol
- [ ] VR/AR compositor
- [ ] Mobile port (ARM)

---

## License

MIT License - See LICENSE file

---

**NEXUS OS**: The internet is the computer.
