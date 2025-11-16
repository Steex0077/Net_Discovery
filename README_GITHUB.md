# 🔍 Network Discovery Tool

A fast and efficient network reconnaissance tool using reverse DNS lookups to map network topology and identify connected devices.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-89e051.svg)](https://www.gnu.org/software/bash/)
[![Security](https://img.shields.io/badge/Security-Pentest-red.svg)](https://en.wikipedia.org/wiki/Penetration_test)

## 🚀 Overview

Network Discovery Tool performs efficient network reconnaissance by querying reverse DNS records to discover active hosts and their hostnames. This tool is particularly useful for cybersecurity professionals, network administrators, and penetration testers who need to quickly map network topology without generating excessive network traffic.

### ✨ Key Features

- **🔍 Reverse DNS Discovery**: Maps IP addresses to hostnames using DNS queries
- **📊 Multiple Output Formats**: Table, CSV, JSON, and Nmap-compatible formats
- **⚡ Customizable Scanning**: Configurable IP ranges, DNS servers, and timeouts
- **📁 Export Capabilities**: Save results to files for further analysis
- **🔧 Flexible Configuration**: Support for different networks and DNS servers
- **📈 Progress Tracking**: Verbose mode with real-time scanning progress
- **🛠️ Easy Integration**: Compatible with nmap and other security tools

## 📋 Table of Contents

- [Installation](#-installation)
- [Usage](#-usage)
- [Examples](#-examples)
- [Output Formats](#-output-formats)
- [Integration](#-integration)
- [Security Considerations](#-security-considerations)
- [Contributing](#-contributing)
- [License](#-license)

## 💾 Installation

### Prerequisites

The tool requires the `dig` command (part of DNS utilities):

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install dnsutils
```

#### CentOS/RHEL/Fedora:
```bash
sudo yum install bind-utils
# or for newer versions:
sudo dnf install bind-utils
```

#### macOS:
```bash
brew install bind
```

### Quick Install

```bash
# Download the script
wget https://raw.githubusercontent.com/Steex0077/network-discovery/main/network_discovery.sh

# Make it executable
chmod +x network_discovery.sh

# Optional: Install system-wide
sudo mv network_discovery.sh /usr/local/bin/
```

### Build from Source

```bash
git clone https://github.com/Steex0077/network-discovery.git
cd network-discovery
chmod +x network_discovery.sh

# Optional: Install to system path
sudo cp network_discovery.sh /usr/local/bin/
```

## 🔧 Usage

### Basic Syntax

```bash
./network_discovery.sh [OPTIONS]
```

### Options

| Option | Long Option | Description | Default |
|--------|-------------|-------------|---------|
| `-d` | `--dns` | DNS server to query | `192.168.0.1` |
| `-n` | `--network` | Network prefix (e.g., 192.168.1) | `192.168.0` |
| `-s` | `--start` | Starting IP number | `1` |
| `-e` | `--end` | Ending IP number | `254` |
| `-o` | `--output` | Output file path | `stdout` |
| `-f` | `--format` | Output format | `table` |
| `-t` | `--timeout` | Timeout per query (seconds) | `2` |
| `-v` | `--verbose` | Enable verbose output | `false` |
| `-h` | `--help` | Show help message | - |

### Output Formats

- **`table`**: Human-readable formatted table (default)
- **`csv`**: Comma-separated values for spreadsheet import
- **`json`**: JSON format for programmatic processing
- **`nmap`**: IP addresses only, compatible with nmap `-iL` option

## 📚 Examples

### Basic Network Scan

Scan the default network (192.168.0.1-254):

```bash
./network_discovery.sh
```

**Output:**
```
📋 Network Discovery Results
=============================
IP Address      | Hostname                     
-----------------+------------------------------
192.168.0.1     | router.local
192.168.0.10    | laptop-john.local
192.168.0.20    | iphone-mary.local
192.168.0.100   | printer.local

📊 Total devices found: 4
```

### Custom Network and DNS Server

Scan a different network using a custom DNS server:

```bash
./network_discovery.sh -n 10.0.1 -d 10.0.1.1
```

### Export to CSV

Generate a CSV file for spreadsheet analysis:

```bash
./network_discovery.sh -f csv -o network_devices.csv
```

**CSV Output:**
```csv
IP,Hostname
192.168.0.1,router.local
192.168.0.10,laptop-john.local
192.168.0.20,iphone-mary.local
```

### Generate Targets for Nmap

Create a target list for nmap scanning:

```bash
# Generate target list
./network_discovery.sh -f nmap -o targets.txt

# Use with nmap
nmap -sV -sC -iL targets.txt
```

### Verbose Scanning

Monitor scanning progress in real-time:

```bash
./network_discovery.sh -v
```

**Verbose Output:**
```
🔍 Scanning network 192.168.0.1-254 via DNS 192.168.0.1
⏱️  Timeout: 2s per query

[13:45:23] Testing 192.168.0.1
[13:45:23] ✅ Found: 192.168.0.1|router.local
[13:45:25] Testing 192.168.0.10
[13:45:25] ✅ Found: 192.168.0.10|laptop-john.local
...
```

### JSON Output for Automation

Perfect for integration with other tools:

```bash
./network_discovery.sh -f json -o network.json
```

**JSON Output:**
```json
{
  "scan_info": {
    "network": "192.168.0.0/24",
    "dns_server": "192.168.0.1",
    "timestamp": "2025-11-16T13:45:23Z",
    "total_found": 4
  },
  "hosts": [
    {"ip": "192.168.0.1", "hostname": "router.local"},
    {"ip": "192.168.0.10", "hostname": "laptop-john.local"}
  ]
}
```

### Limited IP Range

Scan only a specific range of IPs:

```bash
./network_discovery.sh -s 10 -e 50
```

### Corporate Network Scanning

Scan a corporate network with custom timeout:

```bash
./network_discovery.sh -n 172.16.1 -d 172.16.1.1 -t 5 -v -o corporate_devices.csv -f csv
```

## 🔗 Integration

### With Nmap (Port Scanning)

```bash
# Discover hosts first
./network_discovery.sh -f nmap > active_hosts.txt

# Perform detailed port scanning
nmap -sV -sC -A -iL active_hosts.txt -oA detailed_scan
```

### With Security Tools

```bash
# Generate target list for vulnerability scanners
./network_discovery.sh -f nmap > targets.txt

# Use with Nessus, OpenVAS, or other scanners
# Import targets.txt into your preferred scanner
```

### Automated Monitoring

```bash
#!/bin/bash
# Daily network monitoring script

DATE=$(date +%Y%m%d)
./network_discovery.sh -f json -o "network_scan_${DATE}.json"

# Compare with previous day
if [[ -f "network_scan_$(date -d "yesterday" +%Y%m%d).json" ]]; then
    echo "Checking for network changes..."
    # Add comparison logic here
fi
```

### Cron Job for Regular Scanning

```bash
# Add to crontab (crontab -e)
# Scan network every 6 hours
0 */6 * * * /usr/local/bin/network_discovery.sh -f json -o /var/log/network_$(date +\%Y\%m\%d_\%H\%M).json
```

## 🛡️ Security Considerations

### Ethical Use

This tool is designed for **legitimate security testing** and **network administration** purposes only. Users must:

- ✅ Have explicit permission to scan target networks
- ✅ Use only on networks they own or have authorization to test
- ✅ Follow responsible disclosure practices
- ✅ Comply with local laws and regulations

### Stealth Considerations

- **Low Traffic**: Uses only DNS queries, generating minimal network traffic
- **Non-Intrusive**: Does not attempt connections to discovered hosts
- **Configurable Timeout**: Adjustable delays to avoid detection

### Privacy Notes

- **Hostname Disclosure**: May reveal internal naming conventions
- **Network Topology**: Can map internal network structure
- **Device Identification**: Hostnames may indicate device types/users

## 🔧 Troubleshooting

### Common Issues

#### "dig: command not found"
```bash
# Install DNS utilities
sudo apt install dnsutils  # Ubuntu/Debian
sudo yum install bind-utils # CentOS/RHEL
```

#### No Results Returned
```bash
# Test DNS server connectivity
dig @192.168.0.1 google.com

# Test manual reverse lookup
dig @192.168.0.1 -x 192.168.0.1
```

#### Slow Performance
```bash
# Reduce timeout and IP range
./network_discovery.sh -t 1 -s 1 -e 50
```

#### Permission Denied
```bash
# Make script executable
chmod +x network_discovery.sh
```

## 🏗️ Technical Details

### How It Works

1. **IP Generation**: Creates IP addresses within specified range
2. **Reverse DNS Query**: Uses `dig` to query PTR records
3. **Result Processing**: Filters and formats responses
4. **Output Generation**: Produces results in specified format

### Performance

- **Speed**: ~2-3 seconds per IP (depends on DNS response time)
- **Memory**: Minimal memory usage (~1-2MB)
- **Network**: Only DNS queries (UDP/53)

### Dependencies

- **Bash**: Version 4.0 or higher
- **dig**: DNS lookup utility
- **timeout**: Command timeout utility (usually built-in)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/Steex0077/network-discovery.git
cd network-discovery
```

### Running Tests

```bash
# Test basic functionality
./test_network_discovery.sh

# Test different formats
./network_discovery.sh -f json | jq .
./network_discovery.sh -f csv | head
```

### Code Style

- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use meaningful variable names
- Comment complex logic
- Test on multiple environments

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Inspired by**: Traditional network discovery techniques used in penetration testing
- **DNS Utilities**: Built on the robust `dig` command from ISC BIND
- **Security Community**: Thanks to the cybersecurity community for feedback and suggestions

## 🔮 Roadmap

- [ ] **Performance Optimization**: Parallel DNS queries
- [ ] **Additional Output Formats**: XML, YAML support
- [ ] **Enhanced Filtering**: Device type detection
- [ ] **Integration APIs**: REST API for remote scanning
- [ ] **GUI Interface**: Web-based management interface

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Steex0077/network-discovery/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Steex0077/network-discovery/discussions)


---

**⭐ If you find this tool useful, please give it a star on GitHub!**

*Made with ❤️ for the cybersecurity community*
