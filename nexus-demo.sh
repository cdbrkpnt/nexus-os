#!/bin/bash
# nexus-demo.sh - Simulate NEXUS OS experience

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║              NEXUS OS v1.0.0 (Genesis)                     ║"
echo "║                                                            ║"
echo "║           Network-Native Operating System                  ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
sleep 1

echo "[BOOT] Loading kernel... ██████████████████████████████ 100%"
sleep 0.5
echo "[BOOT] Mounting network filesystem... ████████████████████ 100%"
sleep 0.5
echo "[BOOT] Initializing cryptographic identity..."
sleep 1

# Generate fake DID
DID="did:nexus:z6Mkf$(openssl rand -hex 8 2>/dev/null || echo 'a1b2c3d4e5f6')"
echo "[BOOT] Identity: $DID"
sleep 0.5

echo "[BOOT] Connecting to home pod..."
sleep 1
echo "[BOOT] Home pod: connected (12ms latency)"
sleep 0.5

echo "[BOOT] Starting agent daemon..."
sleep 0.5
echo "[BOOT] Active agents:"
echo "         • market-monitor    [WAKE-ON-INTENT]"
echo "         • news-aggregator   [WAKE-ON-INTENT]"
echo "         • presence-tracker  [ALWAYS-ON]"
sleep 0.5

echo "[BOOT] Starting network desktop..."
sleep 1

clear

# Simulate desktop
while true; do
    # Clear screen and draw desktop
    clear

    # Header
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║  NEXUS OS    Network: ● Connected    Latency: 12ms    Identity: %s...  ║\n" "${DID:0:24}"
    printf "╠══════════════╦══════════════════════════════════════════════════╦════════════╣\n"

    # Row 1: Tiles | Desktop | Presence
    printf "║ LIVE TILES   ║                                                  ║ PRESENCE   ║\n"
    printf "║              ║              NEXUS Desktop                       ║            ║\n"
    printf "║ NIFTY        ║                                                  ║ ● You      ║\n"
    printf "║ 19,450       ║   ┌────────┐  ┌────────┐  ┌────────┐           ║ ● Alice    ║\n"
    printf "║ +1.2%%        ║   │Terminal│  │ Files  │  │ Game   │           ║   (doc1)   ║\n"
    printf "║              ║   │        │  │        │  │ Stream │           ║            ║\n"
    printf "║ BTC          ║   │   >_   │  │   📁   │  │   🎮   │           ║ ● Bob      ║\n"
    printf "║ $67,230      ║   └────────┘  └────────┘  └────────┘           ║   (game)   ║\n"
    printf "║ +2.1%%        ║                                                  ║            ║\n"
    printf "║              ║                                                  ║            ║\n"

    # Row 2: Stats | More apps | Empty
    printf "║ Agents: 3    ║   ┌────────┐  ┌────────┐  ┌────────┐           ║            ║\n"
    printf "║              ║   │Browser │  │ Agent  │  │Settings│           ║            ║\n"
    printf "║ Network FS   ║   │ Killer │  │ Monitor│  │        │           ║            ║\n"
    printf "║ Synced: 2s   ║   │   🌐   │  │   🤖   │  │   ⚙️   │           ║            ║\n"
    printf "║ Cache:3/10GB ║   └────────┘  └────────┘  └────────┘           ║            ║\n"

    # Footer
    printf "╠══════════════╩══════════════════════════════════════════════════╩════════════╣\n"
    printf "║  Commands: [t]erminal  [f]iles  [n]et  [g]ame  [a]gents  [q]uit              ║\n"
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n"

    read -p "nexus:~$ " cmd

    case $cmd in
        t|terminal)
            echo ""
            echo "NEXUS Terminal v1.0"
            echo "Identity: $DID"
            echo "Home Pod: connected (12ms latency)"
            echo ""
            echo "Type 'help' for commands, 'exit' to return to desktop"
            echo ""

            # Simulate filesystem state (compatible with bash 3.2)
            CURRENT_DIR="/"

            # Filesystem stored as flat variables (macOS bash 3.2 compatible)
            FS_ROOT="Documents/    Photos/    Agents/    Games/"
            FS_Documents="report.pdf    trading-data.csv    notes.md"
            FS_Photos="IMG_001.jpg    IMG_002.jpg    screenshot.png"
            FS_Agents="market-monitor.cfg    news-aggregator.cfg"
            FS_Games="cyberworld.save    racing.cfg"

            # Helper function to get directory contents
            get_dir_contents() {
                local path="$1"
                case "$path" in
                    "/") echo "$FS_ROOT" ;;
                    "/Documents") echo "$FS_Documents" ;;
                    "/Photos") echo "$FS_Photos" ;;
                    "/Agents") echo "$FS_Agents" ;;
                    "/Games") echo "$FS_Games" ;;
                    *) echo "" ;;
                esac
            }

            # Helper function to check if directory exists
            dir_exists() {
                local path="$1"
                case "$path" in
                    "/"|"/Documents"|"/Photos"|"/Agents"|"/Games") return 0 ;;
                    *) return 1 ;;
                esac
            }

            while true; do
                read -p "nexus:${CURRENT_DIR}$ " term_cmd

                # Skip empty input
                [ -z "$term_cmd" ] && continue

                # Parse command and arguments properly
                cmd=$(echo "$term_cmd" | awk '{print $1}')
                arg=$(echo "$term_cmd" | cut -d' ' -f2-)

                # Fix: if no argument, set arg to empty
                if [ "$arg" == "$term_cmd" ]; then
                    arg=""
                fi

                case $cmd in
                    exit) break ;;

                    help)
                        echo "Available commands:"
                        echo "  ls [path]     - List directory contents"
                        echo "  cd <path>     - Change directory"
                        echo "  pwd           - Print working directory"
                        echo "  cat <file>    - Display file contents"
                        echo "  agents        - List active agents"
                        echo "  spawn <type>  - Spawn new agent"
                        echo "  net <url>     - Fetch network resource"
                        echo "  id            - Show identity info"
                        echo "  clear         - Clear terminal"
                        echo "  exit          - Return to desktop"
                        ;;

                    ls)
                        target="${arg:-$CURRENT_DIR}"
                        # Normalize path
                        if [[ "$target" != /* ]]; then
                            if [ "$CURRENT_DIR" == "/" ]; then
                                target="/$target"
                            else
                                target="$CURRENT_DIR/$target"
                            fi
                        fi
                        # Remove trailing slash
                        target="${target%/}"
                        [ -z "$target" ] && target="/"

                        contents=$(get_dir_contents "$target")
                        if [ -n "$contents" ]; then
                            echo "$contents"
                        else
                            echo "ls: cannot access '$target': No such object in network filesystem"
                        fi
                        ;;

                    cd)
                        # Handle cd with no args (go home)
                        if [ -z "$arg" ]; then
                            CURRENT_DIR="/"
                        # Handle cd ~
                        elif [ "$arg" == "~" ]; then
                            CURRENT_DIR="/"
                        # Handle cd ..
                        elif [ "$arg" == ".." ]; then
                            if [ "$CURRENT_DIR" != "/" ]; then
                                CURRENT_DIR="${CURRENT_DIR%/*}"
                                [ -z "$CURRENT_DIR" ] && CURRENT_DIR="/"
                            fi
                        # Handle cd to specific path
                        else
                            # Remove trailing slash if present
                            clean_arg="${arg%/}"

                            # Build full path
                            if [[ "$clean_arg" == /* ]]; then
                                # Absolute path
                                newpath="$clean_arg"
                            else
                                # Relative path
                                if [ "$CURRENT_DIR" == "/" ]; then
                                    newpath="/$clean_arg"
                                else
                                    newpath="$CURRENT_DIR/$clean_arg"
                                fi
                            fi

                            # Check if path exists in filesystem
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
                            # Simulate file contents
                            case "$arg" in
                                *.md|*.txt)
                                    echo "# Sample content for $arg"
                                    echo "This is a network-native file."
                                    echo "Content hash: bafybei$(date +%s | md5sum | head -c 16)..."
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
                                *)
                                    echo "cat: $arg: No such file or unsupported format"
                                    ;;
                            esac
                        fi
                        ;;

                    agents)
                        echo "Active agents:"
                        echo "  agent-0-...  market-monitor    [WAKE-ON-INTENT]"
                        echo "  agent-1-...  news-aggregator   [WAKE-ON-INTENT]"
                        echo "  agent-2-...  presence-tracker  [ALWAYS-ON]"
                        ;;

                    spawn)
                        if [ -z "$arg" ] || [ "$arg" == "$cmd" ]; then
                            echo "Usage: spawn <agent-type> [options]"
                            echo "Types: market-monitor, news-aggregator, trading-bot, game-npc"
                        else
                            agent_type=${arg%% *}
                            echo "Spawning agent: $agent_type"
                            echo "Agent ID: agent-$(date +%s)"
                            echo "Home Pod: provisioning..."
                            sleep 0.5
                            echo "Status: ACTIVE"
                        fi
                        ;;

                    net)
                        if [ -z "$arg" ] || [ "$arg" == "$cmd" ]; then
                            echo "Usage: net <url>"
                        else
                            echo "Fetching: $arg"
                            echo "Type: application/nexus-object+json"
                            sleep 0.3
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
                        if [ -n "$term_cmd" ]; then
                            echo "Command not found: $cmd"
                            echo "Type 'help' for available commands"
                        fi
                        ;;
                esac
            done

            ;;
        
        f|files)
            echo ""
            echo "NEXUS Files v1.0 - Network File Manager"
            echo "View: /mnt/nexus-root"
            echo ""
            echo "Contents of /:"
            echo "  [DIR]  Documents/          (synced 2s ago)"
            echo "  [DIR]  Photos/             (synced 5s ago)"
            echo "  [FILE] report.pdf          (bafybeihdwdcefgh...)"
            echo "  [FILE] trading-data.csv    (bafybeijk123456...)"
            echo "  [LIVE] @market-ticker      (real-time)"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        n|net)
            echo ""
            echo "NEXUS Net v1.0 - Browser Killer"
            echo "Internet access without browser."
            echo ""
            read -p "Enter URL: " url
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
            read -p "Press Enter to continue..."
            ;;
        g|game)
            echo ""
            echo "NEXUS Game v1.0 - Network-Native Gaming"
            echo ""
            echo "Available games:"
            echo "  1. CyberWorld RPG          [2,847 online]"
            echo "  2. Racing Legends          [1,203 online]"
            echo "  3. Space Strategy          [5,691 online]"
            echo ""
            read -p "Select game (1-3): " game
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
            read -p "Press Enter to continue..."
            ;;
        a|agents)
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
            read -p "Press Enter to continue..."
            ;;
        q|quit)
            echo ""
            echo "Shutting down NEXUS OS..."
            echo "Syncing state to home pod..."
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Unknown command: $cmd"
            sleep 1
            ;;
    esac

    clear
done
