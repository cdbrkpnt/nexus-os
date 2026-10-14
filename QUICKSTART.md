# NEXUS OS - Quick Start Guide

## 5-Minute Setup

### 1. Create Bootable USB

```bash
# Download
wget https://nexus-os.org/releases/nexus-os-1.0.0.iso

# Write to USB (BE CAREFUL - replace sdX!)
sudo dd if=nexus-os-1.0.0.iso of=/dev/sdX bs=4M status=progress
sync
```

### 2. Boot

1. Insert USB
2. Reboot computer
3. Enter boot menu (usually F12, F2, or Del)
4. Select USB drive
5. Choose "NEXUS OS - Live"

### 3. First Boot Wizard

```
┌─────────────────────────────────────────┐
│  NEXUS OS Setup                         │
├─────────────────────────────────────────┤
│                                         │
│  ☐ Generate new identity                │
│  ☐ Restore from existing key            │
│                                         │
│  Home Pod: [auto-detect        ]        │
│                                         │
│  [Continue]  [Advanced]                 │
│                                         │
└─────────────────────────────────────────┘
```

### 4. Desktop

You'll see:
- **Left panel**: Live tiles (market data, news, agents)
- **Center**: Active apps (terminal, files, etc.)
- **Right**: Presence (who's online, shared docs)
- **Top**: Network status, identity, latency

### 5. Try It

**Terminal:**
```bash
nexus-term
nexus:~$ ls
nexus:~$ agents
nexus:~$ spawn market-monitor NIFTY 2.0
```

**Files:**
```bash
nexus-files
# Browse network objects
```

**Internet (no browser):**
```bash
nexus-net fetch https://news.ycombinator.com
# Renders as native app, not web page
```

**Gaming:**
```bash
nexus-game play bafybeigame001...
```

---

## Install to Disk

From live session:
```bash
sudo nexus-install
# Follow prompts
```

Or manual:
```bash
sudo ./scripts/install-to-disk.sh
```

---

## Troubleshooting

**No network?**
- Check: `ip link`
- WiFi: `nexus-wifi connect SSID password`

**Slow performance?**
- Reduce cache: edit `/etc/nexus/nexus.conf`
- Disable live tiles: `nexus-desktop --no-tiles`

**Identity issues?**
- Backup: `cp /etc/nexus/identity.key /mnt/usb/`
- Restore: `cp /mnt/usb/identity.key /etc/nexus/`

---

## Get Help

- Docs: https://nexus-os.org/docs
- Community: https://community.nexus-os.org
- Issues: https://github.com/nexus-os/nexus/issues
