#!/usr/bin/env bash
# net.sh — bash-frameheader networking lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# CONNECTIVITY
# ==============================================================================

# Check if the system has a working internet connection
# Tries multiple endpoints in case one is down
net::is_online() {
    local endpoints=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    for endpoint in "${endpoints[@]}"; do
        if ping -c 1 -W 2 "$endpoint" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

# Check if a specific host is reachable
# Usage: net::can_reach host [timeout_seconds]
net::can_reach() {
    ping -c 1 -W "${2:-2}" "$1" >/dev/null 2>&1
}

# Ping a host and return average round-trip time in ms
# Usage: net::ping host [count]
net::ping() {
    ping -c "${2:-4}" "$1" 2>/dev/null | \
        tail -1 | awk -F'/' '{print $5}'
}

# Check if a TCP port is open on a host
# Usage: net::port::is_open host port [timeout]
net::port::is_open() {
    if runtime::has_command nc; then
        nc -z -w "${3:-2}" "$1" "$2" >/dev/null 2>&1
    elif runtime::has_command bash; then
        # Pure bash /dev/tcp trick
        (echo >/dev/tcp/"$1"/"$2") >/dev/null 2>&1
    else
        return 1
    fi
}

# Wait until a port is open (useful for service readiness checks)
# Usage: net::port::wait host port [timeout_seconds] [interval]
net::port::wait() {
    local elapsed=0
    while (( elapsed < ${3:-30} )); do
        net::port::is_open "$1" "$2" && return 0
        sleep "${4:-1}"
        (( elapsed += ${4:-1} ))
    done
    return 1
}

# Scan common ports on a host, print open ones
# Usage: net::port::scan host [start_port] [end_port]
net::port::scan() {
    local port
    for (( port=${2:-1}; port<=${3:-1024}; port++ )); do
        net::port::is_open "$1" "$port" 1 && echo "$port"
    done
}

# ==============================================================================
# IP ADDRESS
# ==============================================================================

# Get local IP address (first non-loopback)
net::ip::local() {
    if runtime::has_command ip; then
        ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}'
    elif runtime::has_command ifconfig; then
        ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '127.0.0.1' | head -1
    fi
}

# Get public IP address
# Tries multiple services with fallback
net::ip::public() {
    local services=(
        "https://api.ipify.org"
        "https://ifconfig.me/ip"
        "https://icanhazip.com"
        "https://checkip.amazonaws.com"
    )
    local fetcher
    if runtime::has_command curl; then
        fetcher="curl -sf --max-time 5"
    elif runtime::has_command wget; then
        fetcher="wget -qO- --timeout=5"
    else
        echo "net::ip::public: requires curl or wget" >&2
        return 1
    fi

    for svc in "${services[@]}"; do
        local result
        result=$($fetcher "$svc" 2>/dev/null | tr -d '[:space:]')
        if [[ -n "$result" ]]; then
            echo "$result"
            return 0
        fi
    done

    echo "net::ip::public: all endpoints failed" >&2
    return 1
}

# Get all local IP addresses (one per line)
net::ip::all() {
    if runtime::has_command ip; then
        ip addr show 2>/dev/null | awk '/inet /{gsub(/\/.*/, "", $2); print $2}'
    elif runtime::has_command ifconfig; then
        ifconfig 2>/dev/null | awk '/inet /{print $2}'
    fi
}

# Check if a string is a valid IPv4 address
net::ip::is_valid_v4() {
    [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    local IFS='.'
    local -a octets=($1)
    for o in "${octets[@]}"; do
        (( o >= 0 && o <= 255 )) || return 1
    done
}

# Check if a string is a valid IPv6 address (basic check)
net::ip::is_valid_v6() {
    [[ "$1" =~ ^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$ ]]
}

# Check if IP is in private range
net::ip::is_private() {
    net::ip::is_valid_v4 "$1" || return 1
    [[ "$1" =~ ^10\. ]] && return 0
    [[ "$1" =~ ^192\.168\. ]] && return 0
    [[ "$1" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
    return 1
}

# Check if IP is loopback
net::ip::is_loopback() {
    [[ "$1" == "127."* || "$1" == "::1" ]]
}

# ==============================================================================
# HOSTNAME / DNS
# ==============================================================================

# Get the system hostname
net::hostname() {
    hostname 2>/dev/null || cat /etc/hostname 2>/dev/null
}

# Get the fully qualified domain name
net::hostname::fqdn() {
    hostname -f 2>/dev/null
}

# Resolve hostname to IP
# Usage: net::resolve hostname
net::resolve() {
    if runtime::has_command dig; then
        dig +short "$1" 2>/dev/null | grep -E '^[0-9]+\.' | head -1
    elif runtime::has_command nslookup; then
        nslookup "$1" 2>/dev/null | awk '/^Address:/{print $2}' | grep -v '#' | head -1
    elif runtime::has_command getent; then
        getent hosts "$1" 2>/dev/null | awk '{print $1}' | head -1
    else
        ping -c 1 "$1" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
    fi
}

# Reverse DNS lookup — IP to hostname
# Usage: net::resolve::reverse ip
net::resolve::reverse() {
    if runtime::has_command dig; then
        dig +short -x "$1" 2>/dev/null
    elif runtime::has_command nslookup; then
        nslookup "$1" 2>/dev/null | awk '/name =/{print $NF}'
    elif runtime::has_command getent; then
        getent hosts "$1" 2>/dev/null | awk '{print $NF}'
    fi
}

# Get all DNS records of a type
# Usage: net::dns::records hostname [type]
net::dns::records() {
    if runtime::has_command dig; then
        dig +short "$1" "${2:-A}" 2>/dev/null
    elif runtime::has_command nslookup; then
        nslookup -type="${2:-A}" "$1" 2>/dev/null
    fi
}

# Get MX records for a domain
net::dns::mx() {
    net::dns::records "$1" MX
}

# Get TXT records (useful for SPF, DKIM etc.)
net::dns::txt() {
    net::dns::records "$1" TXT
}

# Get nameservers for a domain
net::dns::ns() {
    net::dns::records "$1" NS
}

# Check DNS propagation — query multiple public resolvers
# Usage: net::dns::propagation hostname
net::dns::propagation() {
    local -A resolvers=(
        ["Google"]="8.8.8.8"
        ["Cloudflare"]="1.1.1.1"
        ["Quad9"]="9.9.9.9"
        ["OpenDNS"]="208.67.222.222"
    )
    if ! runtime::has_command dig; then
        echo "net::dns::propagation: requires dig" >&2
        return 1
    fi
    for name in "${!resolvers[@]}"; do
        local ip="${resolvers[$name]}"
        local result
        result=$(dig +short "@$ip" "$1" 2>/dev/null | tr '\n' ' ')
        printf '%-12s %s\n' "$name" "${result:-[no result]}"
    done
}

# ==============================================================================
# NETWORK INTERFACES
# ==============================================================================

# List all network interfaces
net::interface::list() {
    if runtime::has_command ip; then
        ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/{print $2}' | tr -d ' '
    elif runtime::has_command ifconfig; then
        ifconfig -l 2>/dev/null | tr ' ' '\n'
    elif [[ -d /sys/class/net ]]; then
        ls /sys/class/net/
    fi
}

# Get MAC address of an interface
# Usage: net::mac interface
net::mac() {
    if [[ -f "/sys/class/net/${1}/address" ]]; then
        cat "/sys/class/net/${1}/address"
    elif runtime::has_command ip; then
        ip link show "$1" 2>/dev/null | awk '/ether/{print $2}'
    elif runtime::has_command ifconfig; then
        ifconfig "$1" 2>/dev/null | awk '/ether|HWaddr/{print $2}'
    fi
}

# Get interface speed in Mbps
net::interface::speed() {
    if [[ -f "/sys/class/net/${1}/speed" ]]; then
        cat "/sys/class/net/${1}/speed" > /dev/null 2>&1 || echo "Unknown"
    fi
}

# Check if an interface is up
net::interface::is_up() {
    if [[ -f "/sys/class/net/${1}/operstate" ]]; then
        [[ "$(cat "/sys/class/net/${1}/operstate")" == "up" ]]
    elif runtime::has_command ip; then
        ip link show "$1" 2>/dev/null | grep -q 'state UP'
    fi
}

# Get default gateway
net::gateway() {
    if runtime::has_command ip; then
        ip route show default 2>/dev/null | awk '{print $3; exit}'
    elif runtime::has_command route; then
        route -n 2>/dev/null | awk '/^0\.0\.0\.0/{print $2; exit}'
    fi
}

# Get network interface statistics (rx/tx bytes)
# Usage: net::interface::stats interface
net::interface::stat() {
    local rx tx
    if [[ -f "/sys/class/net/${1}/statistics/rx_bytes" ]]; then
        rx=$(cat "/sys/class/net/${1}/statistics/rx_bytes")
        tx=$(cat "/sys/class/net/${1}/statistics/tx_bytes")
        echo "rx: $rx bytes"
        echo "tx: $tx bytes"
        return
    elif runtime::has_command ip; then
        ip -s link show "$1" 2>/dev/null
        return
    fi

    return 1
}

net::interface::stat::rx() {
    if [[ -f "/sys/class/net/${1}/statistics/rx_bytes" ]]; then
        local rx
        rx=$(cat "/sys/class/net/${1}/statistics/rx_bytes")
        echo "$rx bytes"
        return
    fi
    return 1
}

net::interface::stat::tx() {
    if [[ -f "/sys/class/net/${1}/statistics/tx_bytes" ]]; then
        local tx
        tx=$(cat "/sys/class/net/${1}/statistics/tx_bytes")
        echo "$tx bytes"
        return
    fi
    return 1
}


# ==============================================================================
# FETCH / DOWNLOAD
# ==============================================================================

# Fetch URL contents — curl/wget with fallback
# Usage: net::fetch url [output_file]
net::fetch() {
    if runtime::has_command curl; then
        if [[ "${2:--}" == "-" ]]; then
            curl -sfL --max-time 30 "$1"
        else
            curl -sfL --max-time 30 -o "$2" "$1"
        fi
    elif runtime::has_command wget; then
        if [[ "${2:--}" == "-" ]]; then
            wget -qO- --timeout=30 "$1"
        else
            wget -qO "$2" --timeout=30 "$1"
        fi
    else
        echo "net::fetch: requires curl or wget" >&2
        return 1
    fi
}

# Fetch with progress bar
net::fetch::progress() {
    if runtime::has_command curl; then
        curl -L --progress-bar -o "${2:-$(basename "$1")}" "$1"
    elif runtime::has_command wget; then
        wget --progress=bar -O "${2:-$(basename "$1")}" "$1"
    else
        echo "net::fetch::progress: requires curl or wget" >&2
        return 1
    fi
}

# Fetch with retry on failure
# Usage: net::fetch::retry url [output] [retries] [delay]
net::fetch::retry() {
    local attempt=0
    while (( attempt < ${3:-3} )); do
        net::fetch "$1" "${2:--}" && return 0
        (( attempt++ ))
        echo "net::fetch::retry: attempt $attempt failed, retrying in ${4:-2}s..." >&2
        sleep "${4:-2}"
    done
    echo "net::fetch::retry: all ${3:-3} attempts failed" >&2
    return 1
}

# Check HTTP status code of a URL
# Usage: net::http::status url
net::http::status() {
    if runtime::has_command curl; then
        curl -sLo /dev/null -w '%{http_code}' --max-time 10 "$1" 2>/dev/null
    elif runtime::has_command wget; then
        wget -qS --spider "$1" 2>&1 | awk '/HTTP\//{print $2}' | tail -1
    fi
}

# Check if a URL returns 200 OK
net::http::is_ok() {
    [[ "$(net::http::status "$1")" == "200" ]]
}

# Get response headers
net::http::headers() {
    if runtime::has_command curl; then
        curl -sI --max-time 10 "$1" 2>/dev/null
    elif runtime::has_command wget; then
        wget -qS --spider "$1" 2>&1
    fi
}

# ==============================================================================
# WHOIS / GEO
# ==============================================================================

# Basic whois lookup
net::whois() {
    if runtime::has_command whois; then
        whois "$1" 2>/dev/null
    else
        echo "net::whois: requires whois" >&2
        return 1
    fi
}

# Get geolocation info for an IP (uses ip-api.com free tier)
# Usage: net::ip::geo [ip]  (omit for public IP)
net::ip::geo() {
    net::fetch "http://ip-api.com/json/${1:-}" 2>/dev/null
}
