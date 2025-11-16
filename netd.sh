#!/bin/bash

# Network Discovery Tool via Reverse DNS
# Based on: for i in {1..254}; do dig @192.168.0.1 -x 192.168.0.$i +short; done | grep -v "^$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DNS_SERVER="192.168.0.1"
NETWORK="192.168.0"
START_IP=1
END_IP=254
OUTPUT_FILE=""
FORMAT="table"
TIMEOUT=2
VERBOSE=false

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Network Discovery Tool via Reverse DNS Lookup"
    echo ""
    echo "Options:"
    echo "  -d, --dns SERVER      DNS server to query (default: 192.168.0.1)"
    echo "  -n, --network NET     Network prefix (default: 192.168.0)"
    echo "  -s, --start NUM       Start IP (default: 1)"
    echo "  -e, --end NUM         End IP (default: 254)"
    echo "  -o, --output FILE     Output file"
    echo "  -f, --format FORMAT   Output format: table, csv, json, nmap (default: table)"
    echo "  -t, --timeout SEC     Timeout per query (default: 2)"
    echo "  -v, --verbose         Verbose output"
    echo "  -h, --help            Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Basic scan"
    echo "  $0 -n 10.0.1 -d 10.0.1.1            # Different network"
    echo "  $0 -o network_map.csv -f csv         # CSV output"
    echo "  $0 -f nmap -o targets.txt           # Nmap target format"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dns)
            DNS_SERVER="$2"
            shift 2
            ;;
        -n|--network)
            NETWORK="$2"
            shift 2
            ;;
        -s|--start)
            START_IP="$2"
            shift 2
            ;;
        -e|--end)
            END_IP="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate format
case $FORMAT in
    table|csv|json|nmap) ;;
    *)
        echo -e "${RED}Error: Invalid format '$FORMAT'. Use: table, csv, json, nmap${NC}"
        exit 1
        ;;
esac

# Function to print with timestamp
log() {
    if [[ $VERBOSE == true ]]; then
        echo -e "[$(date '+%H:%M:%S')] $1" >&2
    fi
}

# Function to query reverse DNS
query_reverse_dns() {
    local ip="$1"
    local hostname=$(timeout $TIMEOUT dig @$DNS_SERVER -x $ip +short 2>/dev/null | head -n1)
    
    if [[ -n "$hostname" && "$hostname" != ";" ]]; then
        echo "$ip|$hostname"
    fi
}

# Main scanning function
scan_network() {
    local results=()
    local total=$((END_IP - START_IP + 1))
    local current=0
    
    echo -e "${BLUE}🔍 Scanning network $NETWORK.$START_IP-$END_IP via DNS $DNS_SERVER${NC}" >&2
    echo -e "${BLUE}⏱️  Timeout: ${TIMEOUT}s per query${NC}" >&2
    echo "" >&2
    
    for i in $(seq $START_IP $END_IP); do
        current=$((current + 1))
        
        if [[ $VERBOSE == true ]]; then
            printf "\r[%3d%%] Testing %s.%d" $((current * 100 / total)) "$NETWORK" "$i" >&2
        fi
        
        result=$(query_reverse_dns "$NETWORK.$i")
        if [[ -n "$result" ]]; then
            results+=("$result")
            if [[ $VERBOSE == true ]]; then
                echo "" >&2
                log "${GREEN}Found: $result${NC}"
            fi
        fi
    done
    
    if [[ $VERBOSE == true ]]; then
        echo "" >&2
        echo "" >&2
    fi
    
    # Output results
    case $FORMAT in
        table)
            output_table "${results[@]}"
            ;;
        csv)
            output_csv "${results[@]}"
            ;;
        json)
            output_json "${results[@]}"
            ;;
        nmap)
            output_nmap "${results[@]}"
            ;;
    esac
}

# Output functions
output_table() {
    local results=("$@")
    
    echo -e "${GREEN}📋 Network Discovery Results${NC}"
    echo -e "${GREEN}=============================${NC}"
    printf "%-15s | %-30s\n" "IP Address" "Hostname"
    echo "--------------------------------+--------------------------------"
    
    for result in "${results[@]}"; do
        IFS='|' read -r ip hostname <<< "$result"
        printf "%-15s | %-30s\n" "$ip" "$hostname"
    done
    
    echo ""
    echo -e "${YELLOW}📊 Total devices found: ${#results[@]}${NC}"
}

output_csv() {
    local results=("$@")
    
    echo "IP,Hostname"
    for result in "${results[@]}"; do
        echo "$result" | tr '|' ','
    done
}

output_json() {
    local results=("$@")
    
    echo "{"
    echo "  \"scan_info\": {"
    echo "    \"network\": \"$NETWORK.0/24\","
    echo "    \"dns_server\": \"$DNS_SERVER\","
    echo "    \"timestamp\": \"$(date -Iseconds)\","
    echo "    \"total_found\": ${#results[@]}"
    echo "  },"
    echo "  \"hosts\": ["
    
    local first=true
    for result in "${results[@]}"; do
        IFS='|' read -r ip hostname <<< "$result"
        if [[ $first == true ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "    {\"ip\": \"$ip\", \"hostname\": \"$hostname\"}"
    done
    
    echo ""
    echo "  ]"
    echo "}"
}

output_nmap() {
    local results=("$@")
    
    for result in "${results[@]}"; do
        IFS='|' read -r ip hostname <<< "$result"
        echo "$ip"
    done
}

# Save to file if specified
save_output() {
    if [[ -n "$OUTPUT_FILE" ]]; then
        if [[ -f "$OUTPUT_FILE" ]]; then
            read -p "File $OUTPUT_FILE exists. Overwrite? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Aborted."
                exit 1
            fi
        fi
        
        scan_network > "$OUTPUT_FILE"
        echo -e "${GREEN}✅ Results saved to: $OUTPUT_FILE${NC}" >&2
    else
        scan_network
    fi
}

# Check dependencies
if ! command -v dig &> /dev/null; then
    echo -e "${RED}Error: 'dig' command not found. Please install dnsutils package.${NC}"
    exit 1
fi

# Run the scan
save_output
