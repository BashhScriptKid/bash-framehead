# `net`

Network utilities — connectivity checks, IP addressing, DNS resolution, HTTP fetching, network interface inspection, whois, and geolocation. **38 functions.** No `::fast` variants.

---

## Connectivity

| Function | Description |
|----------|-------------|
| `net::is_online` | Check if the system has a working internet connection (tries multiple endpoints) |
| `net::can_reach` | Check if a specific host is reachable |
| `net::ping` | Ping a host and return average round-trip time in ms |
| `net::port::is_open` | Check if a TCP port is open on a host |
| `net::port::wait` | Wait until a port becomes open (for service readiness checks) |
| `net::port::scan` | Scan a range of ports on a host, print open ones |

```bash
if net::is_online; then
    echo "Connected to the internet"
fi

net::can_reach "github.com" 5 && echo "GitHub is reachable"
net::ping "8.8.8.8" 3          # → 12.5 (avg ms)

# Service readiness
if net::port::wait "db.internal" 5432 30; then
    echo "Database is ready"
fi

# Port scan
net::port::scan "192.168.1.1" 80 443
```

## IP Addresses

| Function | Description |
|----------|-------------|
| `net::ip::local` | Get local IP address (first non-loopback) |
| `net::ip::public` | Get public IP address (tries multiple services with fallback) |
| `net::ip::all` | Get all local IP addresses (one per line) |
| `net::ip::is_valid_v4` | Check if a string is a valid IPv4 address |
| `net::ip::is_valid_v6` | Check if a string is a valid IPv6 address |
| `net::ip::is_private` | Check if IP is in private range (RFC 1918) |
| `net::ip::is_loopback` | Check if IP is loopback (127.0.0.0/8, ::1) |

```bash
net::ip::local             # → 192.168.1.100
net::ip::public            # → 203.0.113.42
net::ip::is_private "10.0.0.1" && echo "Private IP"
```

## Hostname & DNS

| Function | Description |
|----------|-------------|
| `net::hostname` | Get the system hostname |
| `net::hostname::fqdn` | Get the fully qualified domain name |
| `net::resolve` | Resolve hostname to IP |
| `net::resolve::reverse` | Reverse DNS lookup — IP to hostname |
| `net::dns::records` | Get all DNS records of a specified type |
| `net::dns::mx` | Get MX records for a domain |
| `net::dns::txt` | Get TXT records (SPF, DKIM, etc.) |
| `net::dns::ns` | Get nameservers for a domain |
| `net::dns::propagation` | Check DNS propagation across multiple public resolvers |

```bash
net::resolve "google.com"             # → 142.250.80.46
net::resolve::reverse "8.8.8.8"      # → dns.google
net::dns::mx "gmail.com"
net::dns::txt "github.com"
```

## Network Interfaces

| Function | Description |
|----------|-------------|
| `net::interface::list` | List all network interfaces |
| `net::mac` | Get MAC address of an interface |
| `net::interface::speed` | Get interface speed in Mbps |
| `net::interface::is_up` | Check if an interface is up |
| `net::gateway` | Get default gateway |
| `net::interface::stat` | Get interface RX/TX statistics |
| `net::interface::stat::rx` | Get received bytes |
| `net::interface::stat::tx` | Get transmitted bytes |

```bash
net::interface::list     # → lo, eth0, wlan0
net::mac "eth0"           # → 00:1a:2b:3c:4d:5e
net::gateway              # → 192.168.1.1
net::interface::is_up "eth0" && echo "eth0 is up"
```

## HTTP & Fetching

| Function | Description |
|----------|-------------|
| `net::fetch` | Fetch URL contents (curl with wget fallback) |
| `net::fetch::progress` | Fetch with progress bar |
| `net::fetch::retry` | Fetch with retry on failure |
| `net::http::status` | Get HTTP status code of a URL |
| `net::http::is_ok` | Check if a URL returns 200 OK |
| `net::http::headers` | Get response headers |

```bash
net::fetch "https://api.example.com/data.json" "output.json"
net::fetch::retry "https://flaky.service" "output" 5 2
net::http::status "https://example.com"    # → 200
net::http::is_ok "https://example.com" && echo "Service is healthy"
```

## WHOIS & Geolocation

| Function | Description |
|----------|-------------|
| `net::whois` | Basic whois lookup |
| `net::ip::geo` | Get geolocation info for an IP (uses ip-api.com free tier) |

```bash
net::whois "example.com"
net::ip::geo "8.8.8.8"    # → Mountain View, CA, US
net::ip::geo               # Geo-lookup your own public IP
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `curl` or `wget` (for fetch/http functions), `ping`, `whois`, `dig` or `host` (for DNS functions)
