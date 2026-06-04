#!/usr/bin/env bash
# net.sh — bash-frameheader networking lib
# Requires: runtime.sh (runtime::has_command)

# --- CONNECTIVITY ---

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
		local host="$1" timeout="${2:-2}"
		ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
}

# Ping a host and return average round-trip time in ms
# Usage: net::ping host [count]
net::ping() {
		local host="$1" count="${2:-4}"
		ping -c "$count" "$host" 2>/dev/null | \
				tail -1 | awk -F'/' '{print $5}'
}

# Check if a TCP port is open on a host
# Usage: net::port::is_open host port [timeout]
net::port::is_open() {
		local host="$1" port="$2" timeout="${3:-2}"
		if runtime::has_command nc; then
				nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1
		elif runtime::has_command bash; then
				# Pure bash /dev/tcp trick
				(echo >/dev/tcp/"$host"/"$port") >/dev/null 2>&1
		else
				return 1
		fi
}

# Wait until a port is open (useful for service readiness checks)
# Usage: net::port::wait host port [timeout_seconds] [interval]
net::port::wait() {
		local host="$1" port="$2" timeout="${3:-30}" interval="${4:-1}"
		local elapsed=0
		while (( elapsed < timeout )); do
				net::port::is_open "$host" "$port" && return 0
				sleep "$interval"
				(( elapsed += interval ))
		done
		return 1
}

# Scan common ports on a host, print open ones
# Usage: net::port::scan host [start_port] [end_port]
net::port::scan() {
		local host="$1" start="${2:-1}" end="${3:-1024}"
		local port
		for (( port=start; port<=end; port++ )); do
				net::port::is_open "$host" "$port" 1 && echo "$port"
		done
}

# --- IP ADDRESS ---

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
		local ip="$1"
		[[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
		local IFS='.'
# shellcheck disable=SC2206
		local -a octets=($ip)
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
		local ip="$1"
		net::ip::is_valid_v4 "$ip" || return 1
		[[ "$ip" =~ ^10\. ]] && return 0
		[[ "$ip" =~ ^192\.168\. ]] && return 0
		[[ "$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
		return 1
}

# Check if IP is loopback
net::ip::is_loopback() {
		[[ "$1" == "127."* || "$1" == "::1" ]]
}

# --- HOSTNAME / DNS ---

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
		local host="$1" type="${2:-A}"
		if runtime::has_command dig; then
				dig +short "$host" "$type" 2>/dev/null
		elif runtime::has_command nslookup; then
				nslookup -type="$type" "$host" 2>/dev/null
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
		local host="$1"
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
				result=$(dig +short "@$ip" "$host" 2>/dev/null | tr '\n' ' ')
				printf '%-12s %s\n' "$name" "${result:-[no result]}"
		done
}

# --- NETWORK INTERFACES ---

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
		local iface="${1:-eth0}"
		if [[ -f "/sys/class/net/$iface/address" ]]; then
				cat "/sys/class/net/$iface/address"
		elif runtime::has_command ip; then
				ip link show "$iface" 2>/dev/null | awk '/ether/{print $2}'
		elif runtime::has_command ifconfig; then
				ifconfig "$iface" 2>/dev/null | awk '/ether|HWaddr/{print $2}'
		fi
}

# Get interface speed in Mbps
net::interface::speed() {
		local iface="${1:-eth0}"
		if [[ -f "/sys/class/net/$iface/speed" ]]; then
				cat "/sys/class/net/$iface/speed" > /dev/null 2>&1 || echo "Unknown"
		fi
}

# Check if an interface is up
net::interface::is_up() {
		local iface="$1"
		if [[ -f "/sys/class/net/$iface/operstate" ]]; then
				[[ "$(cat "/sys/class/net/$iface/operstate")" == "up" ]]
		elif runtime::has_command ip; then
				ip link show "$iface" 2>/dev/null | grep -q 'state UP'
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
		local iface="${1:-eth0}"
		local rx tx
		if [[ -f "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
				rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes")
				tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes")
				echo "rx: $rx bytes"
				echo "tx: $tx bytes"
				return
		elif runtime::has_command ip; then
				ip -s link show "$iface" 2>/dev/null
				return
		fi

		return 1
}

net::interface::stat::rx() {
		local iface="${1:-eth0}"
		local rx
		if [[ -f "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
				rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes")
				echo "$rx bytes"
				return
		fi
		return 1
}

net::interface::stat::tx() {
		local iface="${1:-eth0}"
		local tx
		if [[ -f "/sys/class/net/$iface/statistics/tx_bytes" ]]; then
				tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes")
				echo "$tx bytes"
				return
		fi
		return 1
}


# --- BACKEND DISPATCH ---

# Detect the best available network control backend.
# Echoes: "nm" (NetworkManager), "ip" (raw iproute2), or "none".
_net::detect_backend() {
		local os
		os=$(runtime::os)
		case "$os" in
				linux|wsl)
						if runtime::has_command nmcli && \
								nmcli -t -f RUNNING general 2>/dev/null | grep -q '^running$'; then
								echo nm
								return
						fi
						if runtime::has_command ip; then
								echo ip
								return
						fi
						;;
		esac
		echo none
}

# Cached backend detection. Populates _NET_BACKEND.
# Idempotent -- safe to call from every write function.
_net::init() {
		if [[ -z "${_NET_BACKEND:-}" ]]; then
				_NET_BACKEND="$(_net::detect_backend)"
		fi
}

# Report the active backend. Useful for callers that need to know
# which control path is in effect.
# Usage: net::backend
net::backend() {
		_net::init
		echo "$_NET_BACKEND"
}

# Guard for write functions. Returns 0 if a backend is available,
# non-zero with a clear error message otherwise.
_net::require_backend() {
		_net::init
		case "$_NET_BACKEND" in
				nm|ip) return 0 ;;
				none)
						echo "net: no supported network control backend (need nmcli or iproute2)" >&2
						return 1
						;;
		esac
}


# --- WIFI CONTROL ---

# List visible WiFi networks.
# Output (nm): tab-separated SSID:SIGNAL:SECURITY:FREQ:CHAN:BARS.
# Output (ip): one SSID per line. The ip backend is best-effort; for rich
# fields (signal, security, freq), use the nm backend.
# Usage: net::wifi::list [ifname]
net::wifi::list() {
		_net::require_backend || return 1
		local ifname="${1:-}"
		case "$_NET_BACKEND" in
				nm)
						if [[ -n "$ifname" ]]; then
								nmcli -t -f SSID,SIGNAL,SECURITY,FREQ,CHAN,BARS \
										device wifi list ifname "$ifname" 2>/dev/null
						else
								nmcli -t -f SSID,SIGNAL,SECURITY,FREQ,CHAN,BARS \
										device wifi list 2>/dev/null
						fi
						;;
				ip)
						if [[ -z "$ifname" ]]; then
								for d in /sys/class/net/*/wireless; do
										[[ -d "$d" ]] && { ifname="${d%/wireless}"; ifname="${ifname##*/}"; break; }
								done
						fi
						[[ -z "$ifname" ]] && { echo "net::wifi::list: no wifi interface" >&2; return 1; }
						iw dev "$ifname" scan 2>/dev/null | \
								awk '
									/^BSS / { if (ssid != "") print ssid; ssid = "" }
									/^[[:space:]]+SSID:[[:space:]]?/ {
											sub(/^[[:space:]]+SSID:[[:space:]]?/, "")
											if ($0 != "") ssid = $0
									}
									END { if (ssid != "") print ssid }
								'
						;;
		esac
}

# List saved/known wifi connection profiles.
# Output: one connection name per line.
# Usage: net::wifi::list::saved
net::wifi::list::saved() {
		_net::require_backend || return 1
		case "$_NET_BACKEND" in
				nm)
						nmcli -t -f NAME,TYPE connection show 2>/dev/null | \
								awk -F: '$2 == "802-11-wireless" || $2 == "wifi" {print $1}'
						;;
				ip)
						# Best-effort: scan common wpa_supplicant config locations.
						local conf
						for conf in /etc/wpa_supplicant/wpa_supplicant.conf \
								/etc/wpa_supplicant.conf \
								"$HOME/.config/wpa_supplicant/wpa_supplicant.conf"; do
								[[ -r "$conf" ]] && { \
										awk -F'"' '/^[[:space:]]*ssid=/{print $2}' "$conf"; \
										return; \
								}
						done
						;;
		esac
}

# Connect to a WiFi network. For WPA2-Personal / open networks only.
# Enterprise / WPA3-EAP not supported in this version.
# Usage: net::wifi::connect <ssid> [password] [ifname]
net::wifi::connect() {
		_net::require_backend || return 1
		local ssid="$1" password="${2:-}" ifname="${3:-}"
		[[ -z "$ssid" ]] && { echo "net::wifi::connect: ssid required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local args=(device wifi connect "$ssid")
						[[ -n "$password" ]] && args+=(password "$password")
						[[ -n "$ifname" ]] && args+=(ifname "$ifname")
						nmcli "${args[@]}"
						;;
				ip)
						echo "net::wifi::connect: ip backend does not support wifi connect; use nm" >&2
						return 1
						;;
		esac
}

# Disconnect from the current WiFi network. With nm, this is non-persistent
# (the autoconnect profile will normally bring the device back up).
# Usage: net::wifi::disconnect [ifname]
net::wifi::disconnect() {
		_net::require_backend || return 1
		local ifname="${1:-}"
		case "$_NET_BACKEND" in
				nm)
						if [[ -n "$ifname" ]]; then
								nmcli device disconnect "$ifname"
						else
								nmcli -t -f DEVICE,TYPE device status 2>/dev/null | \
										awk -F: '$2 == "wifi" {print $1}' | \
										while read -r dev; do
										[[ -n "$dev" ]] && nmcli device disconnect "$dev"
								done
						fi
						;;
				ip)
						if [[ -z "$ifname" ]]; then
								for d in /sys/class/net/*/wireless; do
										[[ -d "$d" ]] && { ifname="${d%/wireless}"; ifname="${ifname##*/}"; break; }
								done
						fi
						[[ -z "$ifname" ]] && { echo "net::wifi::disconnect: no wifi interface" >&2; return 1; }
						iw dev "$ifname" disconnect
						;;
		esac
}

# Forget a saved WiFi network (remove its connection profile).
# Usage: net::wifi::forget <ssid-or-uuid>
net::wifi::forget() {
		_net::require_backend || return 1
		local ident="$1"
		[[ -z "$ident" ]] && { echo "net::wifi::forget: ssid or uuid required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local uuid
						if [[ "$ident" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
								uuid="$ident"
						else
								uuid=$(nmcli -t -f NAME,UUID connection show 2>/dev/null | \
										awk -F: -v n="$ident" '$1 == n {print $2; exit}')
								if [[ -z "$uuid" ]]; then
										echo "net::wifi::forget: connection not found: $ident" >&2
										return 1
								fi
						fi
						nmcli connection delete uuid "$uuid"
						;;
				ip)
						echo "net::wifi::forget: ip backend does not support forget" >&2
						return 1
						;;
		esac
}

# Show current WiFi connection status.
# Output (nm): tab-separated key:value pairs.
# Output (ip): `iw dev link` output verbatim.
# Usage: net::wifi::status [ifname]
net::wifi::status() {
		_net::require_backend || return 1
		local ifname="${1:-}"
		case "$_NET_BACKEND" in
				nm)
						if [[ -n "$ifname" ]]; then
								nmcli -t -f ACTIVE,SSID,BSSID,CHAN,FREQ,SIGNAL,SECURITY \
										device show "$ifname" 2>/dev/null
						else
								nmcli -t -f NAME,STATE,DEVICE connection show --active 2>/dev/null
						fi
						;;
				ip)
						if [[ -z "$ifname" ]]; then
								for d in /sys/class/net/*/wireless; do
										[[ -d "$d" ]] && { ifname="${d%/wireless}"; ifname="${ifname##*/}"; break; }
								done
						fi
						[[ -z "$ifname" ]] && { echo "net::wifi::status: no wifi interface" >&2; return 1; }
						iw dev "$ifname" link
						;;
		esac
}

# --- INTERFACE CONTROL ---

# Bring a network interface up.
# nm: tries `device connect` first (NM-managed devices), then falls through
# to `ip link set up` for unmanaged devices.
# Usage: net::interface::up <name>
net::interface::up() {
		_net::require_backend || return 1
		local name="$1"
		[[ -z "$name" ]] && { echo "net::interface::up: name required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						nmcli device connect "$name" 2>/dev/null || \
								ip link set "$name" up
						;;
				ip)
						ip link set "$name" up
						;;
		esac
}

# Bring a network interface down. Non-persistent with nm (the autoconnect
# profile may bring it back up unless its autoconnect is disabled).
# Usage: net::interface::down <name>
net::interface::down() {
		_net::require_backend || return 1
		local name="$1"
		[[ -z "$name" ]] && { echo "net::interface::down: name required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						nmcli device disconnect "$name"
						;;
				ip)
						ip link set "$name" down
						;;
		esac
}

# Restart a network interface (bounce it). Drops the link, sleeps 1s, brings
# it back up. Network will be briefly unavailable.
# Usage: net::interface::restart <name>
net::interface::restart() {
		_net::require_backend || return 1
		local name="$1"
		[[ -z "$name" ]] && { echo "net::interface::restart: name required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						nmcli device disconnect "$name" 2>/dev/null
						runtime::sleep 1
						nmcli device connect "$name" 2>/dev/null || \
								nmcli connection up "$name"
						;;
				ip)
						ip link set "$name" down
						runtime::sleep 1
						ip link set "$name" up
						;;
		esac
}

# Set MTU on an interface.
# nm: persistent; takes effect on next reconnect. <name> must be the
#     connection name in NM (often same as device name).
# ip: immediate only; not persistent across reboots.
# Usage: net::interface::mtu <name> <mtu>
net::interface::mtu() {
		_net::require_backend || return 1
		local name="$1" mtu="$2"
		[[ -z "$name" || -z "$mtu" ]] && { echo "net::interface::mtu: name and mtu required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						if ! nmcli connection modify "$name" 802-3-ethernet.mtu "$mtu" 2>/dev/null; then
								nmcli connection modify "$name" wifi.mtu "$mtu"
						fi
						;;
				ip)
						ip link set "$name" mtu "$mtu"
						;;
		esac
}

# Set MAC address on an interface.
# nm: persistent; takes effect on next reconnect.
# ip: immediate only. The :persistent flag is a no-op with the ip backend
#     (would require writing to NM dispatch scripts or similar).
# Usage: net::interface::mac <name> <mac> [persistent]
net::interface::mac() {
		_net::require_backend || return 1
		local name="$1" mac="$2" persistent="${3:-}"
		[[ -z "$name" || -z "$mac" ]] && { echo "net::interface::mac: name and mac required" >&2; return 1; }
		if ! [[ "$mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
				echo "net::interface::mac: invalid format (expected xx:xx:xx:xx:xx:xx)" >&2
				return 1
		fi
		case "$_NET_BACKEND" in
				nm)
						if ! nmcli connection modify "$name" 802-3-ethernet.cloned-mac-address "$mac" 2>/dev/null; then
								nmcli connection modify "$name" wifi.cloned-mac-address "$mac"
						fi
						echo "net::interface::mac: takes effect on next reconnect" >&2
						;;
				ip)
						[[ "$persistent" == "yes" ]] && \
								echo "net::interface::mac: :persistent has no effect with ip backend" >&2
						ip link set "$name" address "$mac"
						;;
		esac
}



# --- FETCH / DOWNLOAD ---

# Fetch URL contents — curl/wget with fallback
# Usage: net::fetch url [output_file]
net::fetch() {
		local url="$1" out="${2:--}"
		if runtime::has_command curl; then
				if [[ "$out" == "-" ]]; then
						curl -sfL --max-time 30 "$url"
				else
						curl -sfL --max-time 30 -o "$out" "$url"
				fi
		elif runtime::has_command wget; then
				if [[ "$out" == "-" ]]; then
						wget -qO- --timeout=30 "$url"
				else
						wget -qO "$out" --timeout=30 "$url"
				fi
		else
				echo "net::fetch: requires curl or wget" >&2
				return 1
		fi
}

# Fetch with progress bar
net::fetch::progress() {
		local url="$1"; local out="${2:-$(basename "$url")}"
		if runtime::has_command curl; then
				curl -L --progress-bar -o "$out" "$url"
		elif runtime::has_command wget; then
				wget --progress=bar -O "$out" "$url"
		else
				echo "net::fetch::progress: requires curl or wget" >&2
				return 1
		fi
}

# Fetch with retry on failure
# Usage: net::fetch::retry url [output] [retries] [delay]
net::fetch::retry() {
		local url="$1" out="${2:--}" retries="${3:-3}" delay="${4:-2}"
		local attempt=0
		while (( attempt < retries )); do
				net::fetch "$url" "$out" && return 0
				(( attempt++ ))
				echo "net::fetch::retry: attempt $attempt failed, retrying in ${delay}s..." >&2
				sleep "$delay"
		done
		echo "net::fetch::retry: all $retries attempts failed" >&2
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

# --- WHOIS / GEO ---

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
		local ip="${1:-}"
		local url="http://ip-api.com/json/${ip}"
		net::fetch "$url" 2>/dev/null
}

