# `net::ip::geo`

Get geolocation info for an IP (uses ip-api.com free tier)

## Usage

```bash
net::ip::geo [ip]  (omit for public IP)
```

## Source

```bash
net::ip::geo() {
    local ip="${1:-}"
    local url="http://ip-api.com/json/${ip}"
    net::fetch "$url" 2>/dev/null
}
```

## Module

[`net`](../net.md)
