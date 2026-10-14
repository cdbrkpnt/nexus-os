#!/bin/bash
# NEXUS OS v3.0 - REAL Working Environment
# Actual filesystem, real commands, real editor

NEXUS_ROOT="/tmp/nexus-root"
NEXUS_HOME="$NEXUS_ROOT/home/user"
NEXUS_ID="did:nexus:z6Mkf$(head -c 8 /dev/urandom | xxd -p | head -c 16)"

# Initialize real filesystem
init_filesystem() {
    rm -rf "$NEXUS_ROOT"
    mkdir -p "$NEXUS_HOME"/{Documents,Photos,Agents,Games,Downloads}
    
    # Create real files
    cat > "$NEXUS_HOME/Documents/notes.md" << 'EOF'
# NEXUS OS Notes
Welcome to network-native computing.

## Features
- Cryptographic identity: $NEXUS_ID
- Content-addressed storage
- Real-time sync
EOF
    
    cat > "$NEXUS_HOME/Documents/trading-data.csv" << 'EOF'
date,symbol,price,change
2026-10-14,NIFTY,19450.20,+1.2%
2026-10-14,BTC,67230.50,+2.1%
2026-10-14,ETH,3450.80,+3.4%
EOF
    
    cat > "$NEXUS_HOME/Agents/market-monitor.cfg" << 'EOF'
type=market-monitor
symbol=NIFTY
threshold=2.0
wake_on_intent=true
EOF
    
    echo "NEXUS OS Game Save Data" > "$NEXUS_HOME/Games/cyberworld.save"
    echo "Screenshot placeholder" > "$NEXUS_HOME/Photos/screenshot.png"
}

# Draw desktop
draw_desktop() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║  NEXUS OS    Network: ● Connected    Latency: 12ms    Identity: ${NEXUS_ID:0:28}...  ║"
    echo "╠══════════════╦══════════════════════════════════════════════════╦════════════╣"
    echo "║ LIVE TILES   ║                                                  ║ PRESENCE   ║"
    echo "║              ║              NEXUS Desktop                       ║            ║"
    echo "║ NIFTY        ║                                                  ║ ● You      ║"
    echo "║ 19,450       ║   ┌────────┐  ┌────────┐  ┌────────┐           ║ ● Alice    ║"
    echo "║ +1.2%        ║   │Terminal│  │ Files  │  │ Game   │           ║   (doc1)   ║"
    echo "║              ║   │        │  │        │  │ Stream │           ║            ║"
    echo "║ BTC          ║   │   >_   │  │   📁   │  │   🎮   │           ║ ● Bob      ║"
    echo "║ \$67,230      ║   └────────┘  └────────┘  └────────┘           ║   (game)   ║"
    echo "║ +2.1%        ║                                                  ║            ║"
    echo "║              ║                                                  ║            ║"
    echo "║ Agents: 3    ║   ┌────────┐  ┌────────┐  ┌────────┐           ║            ║"
    echo "║              ║   │Browser │  │ Agent  │  │Settings│           ║            ║"
    echo "║ Network FS   ║   │ Killer │  │ Monitor│  │        │           ║            ║"
    echo "║ Synced: 2s   ║   │   🌐   │  │   🤖   │  │   ⚙️   │           ║            ║"
    echo "║ Cache:3/10GB ║   └────────┘  └────────┘  └────────┘           ║            ║"
    echo "╠══════════════╩══════════════════════════════════════════════════╩════════════╣"
    echo "║  [t]erminal  [f]iles  [n]et  [g]ame  [a]gents  [q]uit                        ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
}

# REAL terminal with actual commands
run_terminal() {
    local cwd="$NEXUS_HOME"
    
    echo ""
    echo "NEXUS Terminal v3.0 - REAL MODE"
    echo "Identity: $NEXUS_ID"
    echo "Home: $cwd"
    echo ""
    echo "Real commands: ls cd pwd cat nano vim echo mkdir rm cp mv touch"
    echo "Type 'exit' to return to desktop"
    echo ""
    
    while true; do
        # Show relative path
        local display_path="${cwd#$NEXUS_HOME}"
        [ -z "$display_path" ] && display_path="~"
        
        printf "nexus:%s$ " "$display_path"
        read -r cmd_line
        
        [ -z "$cmd_line" ] && continue
        
        # Parse command
        local cmd=$(echo "$cmd_line" | awk '{print $1}')
        local args=$(echo "$cmd_line" | cut -d' ' -f2-)
        [ "$args" = "$cmd_line" ] && args=""
        
        case "$cmd" in
            exit)
                return
                ;;
                
            ls)
                if [ -z "$args" ]; then
                    ls -la "$cwd" 2>/dev/null || ls "$cwd"
                else
                    # Handle relative paths
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    ls -la "$target" 2>/dev/null || ls "$target" 2>/dev/null || echo "ls: $args: No such file or directory"
                fi
                ;;
                
            cd)
                if [ -z "$args" ] || [ "$args" = "~" ]; then
                    cwd="$NEXUS_HOME"
                elif [ "$args" = ".." ]; then
                    cwd="$(dirname "$cwd")"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    if [ -d "$target" ]; then
                        cwd="$(cd "$target" && pwd)"
                    else
                        echo "cd: $args: No such file or directory"
                    fi
                fi
                ;;
                
            pwd)
                echo "$cwd"
                ;;
                
            cat)
                if [ -z "$args" ]; then
                    echo "cat: missing file operand"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    if [ -f "$target" ]; then
                        cat "$target"
                    else
                        echo "cat: $args: No such file or directory"
                    fi
                fi
                ;;
                
            nano|vim|vi|emacs)
                local editor="$cmd"
                if [ -z "$args" ]; then
                    echo "$editor: missing file operand"
                    echo "Usage: $editor <filename>"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    # Create parent dir if needed
                    mkdir -p "$(dirname "$target")"
                    # Use real editor
                    if command -v "$editor" >/dev/null 2>&1; then
                        "$editor" "$target"
                    else
                        echo "$editor not installed, using basic editor..."
                        echo "Enter text (Ctrl+D to save):"
                        cat > "$target"
                        echo "Saved: $target"
                    fi
                fi
                ;;
                
            echo)
                echo "$args"
                ;;
                
            mkdir)
                if [ -z "$args" ]; then
                    echo "mkdir: missing operand"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    mkdir -p "$target" && echo "Created: $args"
                fi
                ;;
                
            rm)
                if [ -z "$args" ]; then
                    echo "rm: missing operand"
                else
                    local target="$args"
                    # Handle flags
                    target="${target#-f }"
                    target="${target#-rf }"
                    target="${target#-r }"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    rm -rf "$target" 2>/dev/null && echo "Removed: $args" || echo "rm: $args: No such file or directory"
                fi
                ;;
                
            cp|mv)
                if [ -z "$args" ]; then
                    echo "$cmd: missing file operand"
                else
                    local src=$(echo "$args" | awk '{print $1}')
                    local dst=$(echo "$args" | awk '{print $2}')
                    if [ -z "$dst" ]; then
                        echo "$cmd: missing destination"
                    else
                        [[ "$src" != /* ]] && src="$cwd/$src"
                        [[ "$dst" != /* ]] && dst="$cwd/$dst"
                        "$cmd" "$src" "$dst" 2>/dev/null && echo "$cmd: $src -> $dst" || echo "$cmd: failed"
                    fi
                fi
                ;;
                
            touch)
                if [ -z "$args" ]; then
                    echo "touch: missing file operand"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    touch "$target" && echo "Touched: $args"
                fi
                ;;
                
            grep)
                if [ -z "$args" ]; then
                    echo "grep: missing pattern"
                else
                    local pattern=$(echo "$args" | awk '{print $1}')
                    local file=$(echo "$args" | awk '{print $2}')
                    if [ -n "$file" ]; then
                        [[ "$file" != /* ]] && file="$cwd/$file"
                        grep "$pattern" "$file" 2>/dev/null || echo "No matches"
                    fi
                fi
                ;;
                
            head|tail)
                if [ -z "$args" ]; then
                    echo "$cmd: missing file operand"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    "$cmd" "$target" 2>/dev/null || echo "$cmd: $args: No such file"
                fi
                ;;
                
            wc)
                if [ -z "$args" ]; then
                    echo "wc: missing file operand"
                else
                    local target="$args"
                    [[ "$target" != /* ]] && target="$cwd/$target"
                    wc "$target" 2>/dev/null || echo "wc: $args: No such file"
                fi
                ;;
                
            find)
                if [ -z "$args" ]; then
                    find "$cwd" -maxdepth 2 2>/dev/null
                else
                    find "$cwd" -name "$args" 2>/dev/null
                fi
                ;;
                
            df)
                df -h "$NEXUS_ROOT" 2>/dev/null || echo "Filesystem: NEXUS-FS (virtual)"
                ;;
                
            free)
                free -h 2>/dev/null || echo "Memory: virtual NEXUS environment"
                ;;
                
            ps)
                ps aux 2>/dev/null | head -10 || echo "Running agents: 3"
                ;;
                
            id)
                echo "Identity: $NEXUS_ID"
                echo "Home Pod: connected (12ms latency)"
                echo "Network: QUIC/HTTP3"
                echo "Root: $NEXUS_ROOT"
                ;;
                
            agents)
                echo "Active agents:"
                echo "  agent-0-...  market-monitor     [WAKE-ON-INTENT]"
                echo "  agent-1-...  news-aggregator    [WAKE-ON-INTENT]"
                echo "  agent-2-...  presence-tracker   [ALWAYS-ON]"
                ;;
                
            spawn)
                if [ -z "$args" ]; then
                    echo "Usage: spawn <agent-type>"
                else
                    echo "Spawning agent: $args"
                    echo "Agent ID: agent-$(date +%s)"
                    echo "Status: ACTIVE"
                fi
                ;;
                
            net)
                if [ -z "$args" ]; then
                    echo "Usage: net <url>"
                else
                    echo "Fetching: $args"
                    curl -sL "$args" 2>/dev/null | head -20 || echo "Network: simulated fetch"
                fi
                ;;
                
            clear)
                clear
                ;;
                
            help)
                echo "REAL commands available:"
                echo "  Files: ls cd pwd cat nano vim echo touch"
                echo "  Ops:   mkdir rm cp mv grep find wc head tail"
                echo "  Sys:   df free ps id agents spawn net"
                echo "  Other: clear help exit"
                ;;
                
            *)
                # Try to execute as real command
                if command -v "$cmd" >/dev/null 2>&1; then
                    (cd "$cwd" && eval "$cmd_line") 2>/dev/null || echo "$cmd: command failed"
                else
                    echo "Command not found: $cmd"
                    echo "Type 'help' for available commands"
                fi
                ;;
        esac
    done
}

# Files app - real file manager
run_files() {
    echo ""
    echo "NEXUS Files v3.0 - Real File Manager"
    echo "Root: $NEXUS_ROOT"
    echo ""
    echo "Directory structure:"
    find "$NEXUS_ROOT" -type f -o -type d | sed "s|$NEXUS_ROOT|/|" | head -30
    echo ""
    echo "Total files: $(find "$NEXUS_ROOT" -type f | wc -l)"
    echo "Total size: $(du -sh "$NEXUS_ROOT" 2>/dev/null | cut -f1)"
    echo ""
    read -r -p "Press Enter to continue..."
}

# Net app
run_net() {
    echo ""
    echo "NEXUS Net v3.0 - Browser Killer"
    echo ""
    read -r -p "Enter URL (or 'test'): " url
    
    if [ "$url" = "test" ]; then
        echo ""
        echo "Testing network connectivity..."
        echo "Fetching https://example.com..."
        curl -sI https://example.com 2>/dev/null | head -5 || echo "Network: simulated"
    elif [ -n "$url" ]; then
        echo ""
        echo "Fetching: $url"
        curl -sL "$url" 2>/dev/null | head -30 || echo "Failed to fetch"
    fi
    echo ""
    read -r -p "Press Enter to continue..."
}

# Game app
run_game() {
    echo ""
    echo "NEXUS Game v3.0"
    echo ""
    echo "Available games:"
    echo "  1. CyberWorld RPG"
    echo "  2. Racing Legends"
    echo "  3. Space Strategy"
    echo ""
    read -r -p "Select (1-3): " game
    
    case "$game" in
        1|2|3)
            echo ""
            echo "Launching game $game..."
            echo "State synced to: $NEXUS_HOME/Games/"
            ls -la "$NEXUS_HOME/Games/" 2>/dev/null
            ;;
    esac
    echo ""
    read -r -p "Press Enter to continue..."
}

# Agents monitor
run_agents() {
    echo ""
    echo "NEXUS Agent Monitor"
    echo ""
    echo "Agent configs in: $NEXUS_HOME/Agents/"
    ls -la "$NEXUS_HOME/Agents/" 2>/dev/null
    echo ""
    if [ -f "$NEXUS_HOME/Agents/market-monitor.cfg" ]; then
        echo "market-monitor.cfg contents:"
        cat "$NEXUS_HOME/Agents/market-monitor.cfg"
    fi
    echo ""
    read -r -p "Press Enter to continue..."
}

# Boot
boot() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              NEXUS OS v3.0 (Genesis)                       ║"
    echo "║           Network-Native Operating System                  ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    sleep 0.3
    
    echo "[BOOT] Initializing real filesystem..."
    init_filesystem
    sleep 0.3
    
    echo "[BOOT] Identity: $NEXUS_ID"
    echo "[BOOT] Root: $NEXUS_ROOT"
    echo "[BOOT] Home: $NEXUS_HOME"
    sleep 0.3
    
    echo "[BOOT] Starting agents..."
    echo "       • market-monitor [WAKE-ON-INTENT]"
    echo "       • news-aggregator [WAKE-ON-INTENT]"
    sleep 0.3
    
    echo "[BOOT] Ready."
    sleep 0.5
}

# Main
main() {
    boot
    
    while true; do
        draw_desktop
        printf "nexus:~$ "
        read -r choice
        
        case "$choice" in
            t|terminal)  run_terminal ;;
            f|files)     run_files ;;
            n|net)       run_net ;;
            g|game)      run_game ;;
            a|agents)    run_agents ;;
            q|quit)
                echo ""
                echo "Syncing to home pod..."
                echo "State preserved in: $NEXUS_ROOT"
                echo "Goodbye!"
                exit 0
                ;;
        esac
    done
}

main
