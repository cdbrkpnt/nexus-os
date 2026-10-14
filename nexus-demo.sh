#!/bin/bash
# NEXUS OS Demo v2.0 - Clean rewrite
# Network-Native Operating System simulation

# Generate identity once
DID="did:nexus:z6Mkf$(head -c 8 /dev/urandom | xxd -p | head -c 16)"

# ============================================================
# FILESYSTEM SIMULATION (macOS bash 3.2 compatible)
# ============================================================

FS_ROOT="Documents/    Photos/    Agents/    Games/"
FS_Documents="report.pdf    trading-data.csv    notes.md"
FS_Photos="IMG_001.jpg    IMG_002.jpg    screenshot.png"
FS_Agents="market-monitor.cfg    news-aggregator.cfg"
FS_Games="cyberworld.save    racing.cfg"

get_dir_contents() {
    case "$1" in
        "/")          echo "$FS_ROOT" ;;
        "/Documents") echo "$FS_Documents" ;;
        "/Photos")    echo "$FS_Photos" ;;
        "/Agents")    echo "$FS_Agents" ;;
        "/Games")     echo "$FS_Games" ;;
        *)            echo "" ;;
    esac
}

dir_exists() {
    case "$1" in
        "/"|"/Documents"|"/Photos"|"/Agents"|"/Games") return 0 ;;
        *) return 1 ;;
    esac
}

# ============================================================
# DESKTOP RENDERER
# ============================================================

draw_desktop() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║  NEXUS OS    Network: ● Connected    Latency: 12ms    Identity: ${DID:0:28}...  ║"
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
    echo "║  Commands: [t]erminal  [f]iles  [n]et  [g]ame  [a]gents  [q]uit              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
}

# ============================================================
# TERMINAL EMULATOR
# ============================================================

run_terminal() {
    local CURRENT_DIR="/"
    
    echo ""
    echo "NEXUS Terminal v2.0"
    echo "Identity: $DID"
    echo "Home Pod: connected (12ms latency)"
    echo ""
    echo "Type 'help' for commands, 'exit' to return to desktop"
    echo ""
    
    while true; do
        printf "nexus:%s$ " "$CURRENT_DIR"
        read -r term_cmd
        
        # Skip empty input
        [ -z "$term_cmd" ] && continue
        
        # Parse command and argument
        cmd=$(echo "$term_cmd" | awk '{print $1}')
        arg=$(echo "$term_cmd" | cut -d' ' -f2- 2>/dev/null)
        
        # If arg equals full command, there's no argument
        if [ "$arg" = "$term_cmd" ]; then
            arg=""
        fi
        
        case "$cmd" in
            exit)
                return
                ;;
                
            help)
                echo "Available commands:"
                echo "  ls [path]       List directory contents"
                echo "  cd <path>       Change directory (.. ~ /)"
                echo "  pwd             Print working directory"
                echo "  cat <file>      Display file contents"
                echo "  agents          List active agents"
                echo "  spawn <type>    Spawn new agent"
                echo "  net <url>       Fetch network resource"
                echo "  id              Show identity info"
                echo "  clear           Clear terminal"
                echo "  help            Show this help"
                echo "  exit            Return to desktop"
                ;;
                
            ls)
                local target="$arg"
                [ -z "$target" ] && target="$CURRENT_DIR"
                
                # Handle relative paths
                case "$target" in
                    /*) ;;  # Already absolute
                    *)
                        if [ "$CURRENT_DIR" = "/" ]; then
                            target="/$target"
                        else
                            target="$CURRENT_DIR/$target"
                        fi
                        ;;
                esac
                
                # Remove trailing slash
                target="${target%/}"
                [ -z "$target" ] && target="/"
                
                local contents=$(get_dir_contents "$target")
                if [ -n "$contents" ]; then
                    echo "$contents"
                else
                    echo "ls: cannot access '$target': No such object"
                fi
                ;;
                
            cd)
                if [ -z "$arg" ] || [ "$arg" = "~" ]; then
                    CURRENT_DIR="/"
                elif [ "$arg" = ".." ]; then
                    if [ "$CURRENT_DIR" != "/" ]; then
                        CURRENT_DIR="${CURRENT_DIR%/*}"
                        [ -z "$CURRENT_DIR" ] && CURRENT_DIR="/"
                    fi
                else
                    local clean_arg="${arg%/}"
                    local newpath
                    
                    case "$clean_arg" in
                        /*) newpath="$clean_arg" ;;
                        *)
                            if [ "$CURRENT_DIR" = "/" ]; then
                                newpath="/$clean_arg"
                            else
                                newpath="$CURRENT_DIR/$clean_arg"
                            fi
                            ;;
                    esac
                    
                    if dir_exists "$newpath"; then
                        CURRENT_DIR="$newpath"
                    else
                        echo "cd: no such object: $arg"
                        echo "Hint: Use 'ls' to see available directories"
                    fi
                fi
                ;;
                
            pwd)
                echo "$CURRENT_DIR"
                ;;
                
            cat)
                if [ -z "$arg" ]; then
                    echo "cat: missing file operand"
                else
                    case "$arg" in
                        *.md|*.txt)
                            echo "# Sample content for $arg"
                            echo "This is a network-native file."
                            echo "Content hash: bafybei$(date +%s | md5sum 2>/dev/null | head -c 16 || date +%s | shasum | head -c 16)..."
                            ;;
                        *.csv)
                            echo "date,symbol,price,change"
                            echo "2026-10-14,NIFTY,19450.20,+1.2%"
                            echo "2026-10-14,BTC,67230.50,+2.1%"
                            ;;
                        *.pdf)
                            echo "[PDF content would render as native app]"
                            echo "Use 'nexus-files open $arg' for full viewer"
                            ;;
                        *.cfg)
                            echo "# Agent configuration: $arg"
                            echo "type=market-monitor"
                            echo "wake_on_intent=true"
                            echo "interval=60s"
                            ;;
                        *.save)
                            echo "[Binary game save data]"
                            echo "World state hash: bafybei$(date +%s | md5sum 2>/dev/null | head -c 16 || date +%s | shasum | head -c 16)..."
                            ;;
                        *)
                            echo "cat: $arg: No such file or unsupported format"
                            ;;
                    esac
                fi
                ;;
                
            agents)
                echo "Active agents:"
                echo "  agent-0-1697...  market-monitor     [WAKE-ON-INTENT]"
                echo "  agent-1-1698...  news-aggregator    [WAKE-ON-INTENT]"
                echo "  agent-2-1699...  presence-tracker   [ALWAYS-ON]"
                ;;
                
            spawn)
                if [ -z "$arg" ]; then
                    echo "Usage: spawn <agent-type>"
                    echo "Types: market-monitor, news-aggregator, trading-bot, game-npc"
                else
                    local agent_type=$(echo "$arg" | awk '{print $1}')
                    echo "Spawning agent: $agent_type"
                    echo "Agent ID: agent-$(date +%s)"
                    echo "Home Pod: provisioning..."
                    sleep 0.3
                    echo "Status: ACTIVE"
                fi
                ;;
                
            net)
                if [ -z "$arg" ]; then
                    echo "Usage: net <url>"
                else
                    echo "Fetching: $arg"
                    echo "Type: application/nexus-object+json"
                    sleep 0.2
                    echo ""
                    echo "[UI] Title: Example Content"
                    echo "[UI] Source: $arg"
                    echo "[UI] Rendered as native app window"
                fi
                ;;
                
            id)
                echo "Identity: $DID"
                echo "Home Pod: connected (12ms latency)"
                echo "Network: QUIC/HTTP3"
                echo "Cache: 3.2/10 GB used"
                ;;
                
            clear)
                clear
                ;;
                
            *)
                echo "Command not found: $cmd"
                echo "Type 'help' for available commands"
                ;;
        esac
    done
}

# ============================================================
# OTHER APPS
# ============================================================

run_files() {
    echo ""
    echo "NEXUS Files v2.0 - Network File Manager"
    echo "View: /mnt/nexus-root"
    echo ""
    echo "Contents of /:"
    echo "  [DIR]  Documents/          (synced 2s ago)"
    echo "  [DIR]  Photos/             (synced 5s ago)"
    echo "  [FILE] report.pdf          (bafybeihdwdcefgh...)"
    echo "  [FILE] trading-data.csv    (bafybeijk123456...)"
    echo "  [LIVE] @market-ticker      (real-time)"
    echo ""
    echo "Operations:"
    echo "  open <hash>     Open content-addressed object"
    echo "  pin <hash>      Pin to local cache"
    echo "  share <hash>    Create signed share link"
    echo "  sync            Force sync with home pod"
    echo ""
    read -r -p "Press Enter to continue..."
}

run_net() {
    echo ""
    echo "NEXUS Net v2.0 - Browser Killer"
    echo "Internet access without browser."
    echo ""
    read -r -p "Enter URL: " url
    echo ""
    echo "Fetching: $url"
    echo "Type: application/nexus-object+json"
    echo ""
    echo "Rendering as native app..."
    echo "[UI] Title: Example Article"
    echo "[UI] Author: did:nexus:author123"
    echo "[UI] Content: [structured blocks]"
    echo "[UI] Comments: [live sync enabled]"
    echo ""
    read -r -p "Press Enter to continue..."
}

run_game() {
    echo ""
    echo "NEXUS Game v2.0 - Network-Native Gaming"
    echo ""
    echo "Available games:"
    echo "  1. CyberWorld RPG          [2,847 online]"
    echo "  2. Racing Legends          [1,203 online]"
    echo "  3. Space Strategy          [5,691 online]"
    echo ""
    read -r -p "Select game (1-3): " game
    echo ""
    echo "Launching game..."
    echo "Fetching world state..."
    echo "Syncing with network..."
    echo "Streaming assets..."
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  GAME RUNNING - Persistent World                           ║"
    echo "║  Your state: saved to network in real-time                 ║"
    echo "║  Spectators: can view as ghost (zero bandwidth)            ║"
    echo "║  Mods: live subscription, no installation                  ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    read -r -p "Press Enter to continue..."
}

run_agents() {
    echo ""
    echo "NEXUS Agent Monitor"
    echo ""
    echo "Active agents:"
    echo "┌─────────────────┬─────────────────┬─────────────────┐"
    echo "│ ID              │ Type            │ Status          │"
    echo "├─────────────────┼─────────────────┼─────────────────┤"
    echo "│ agent-1697...   │ market-monitor  │ WAKE-ON-INTENT  │"
    echo "│ agent-1698...   │ news-aggregator │ WAKE-ON-INTENT  │"
    echo "│ agent-1699...   │ presence-tracker│ ALWAYS-ON       │"
    echo "└─────────────────┴─────────────────┴─────────────────┘"
    echo ""
    read -r -p "Press Enter to continue..."
}

# ============================================================
# BOOT SEQUENCE
# ============================================================

boot() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              NEXUS OS v2.0 (Genesis)                       ║"
    echo "║                                                            ║"
    echo "║           Network-Native Operating System                  ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    sleep 0.5
    
    echo "[BOOT] Loading kernel... ██████████████████████████████ 100%"
    sleep 0.3
    echo "[BOOT] Mounting network filesystem... ████████████████████ 100%"
    sleep 0.3
    echo "[BOOT] Initializing cryptographic identity..."
    sleep 0.5
    echo "[BOOT] Identity: $DID"
    sleep 0.3
    echo "[BOOT] Connecting to home pod..."
    sleep 0.5
    echo "[BOOT] Home pod: connected (12ms latency)"
    sleep 0.3
    echo "[BOOT] Starting agent daemon..."
    sleep 0.3
    echo "[BOOT] Active agents:"
    echo "         • market-monitor    [WAKE-ON-INTENT]"
    echo "         • news-aggregator   [WAKE-ON-INTENT]"
    echo "         • presence-tracker  [ALWAYS-ON]"
    sleep 0.3
    echo "[BOOT] Starting network desktop..."
    sleep 0.5
}

# ============================================================
# MAIN LOOP
# ============================================================

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
                echo "Shutting down NEXUS OS..."
                echo "Syncing state to home pod..."
                echo "Goodbye!"
                exit 0
                ;;
            *)
                # Ignore empty or unknown input
                ;;
        esac
    done
}

main
