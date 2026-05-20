# `net::ping`

Ping a host and return average round-trip time in ms

## Usage

```bash
net::ping host [count]
```

## Source

```bash
net::ping() {
    local host="$1" count="${2:-4}"
    ping -c "$count" "$host" 2>/dev/null | \
        tail -1 | awk -F'/' '{print $5}'
}
```

## Module

[`net`](../net.md)
