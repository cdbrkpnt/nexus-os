# Contributing to NEXUS OS

Thank you for your interest in contributing to NEXUS OS!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/nexus-os.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Test: `./nexus-demo.sh`
6. Commit: `git commit -m "Add your feature"`
7. Push: `git push origin feature/your-feature`
8. Open a Pull Request

## Development Setup

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt-get install build-essential libfuse3-dev libsodium-dev     libcurl4-openssl-dev libjson-c-dev libwayland-dev libcairo2-dev

# Build components
gcc -O2 -o nexus-identityd core/identity/nexus-id.c -lsodium
gcc -O2 -o nexus-agentd core/agents/agent-daemon.c -lpthread -lcurl -ljson-c

# Run demo
./nexus-demo.sh
```

## Code Style

- C: Follow Linux kernel style (tabs, 80 columns)
- Shell: Use `shellcheck`, POSIX-compliant where possible
- Documentation: Markdown, keep it concise

## Areas to Contribute

- [ ] FUSE filesystem implementation
- [ ] WASM runtime integration (Wasmtime)
- [ ] Wayland compositor
- [ ] Home pod server
- [ ] App marketplace
- [ ] Game state sync protocol
- [ ] Mobile port (ARM)

## Questions?

Open an issue or join #nexus-os on Libera.Chat.
