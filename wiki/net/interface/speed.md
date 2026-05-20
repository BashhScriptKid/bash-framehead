# `net::interface::speed`

Get interface speed in Mbps

## Source

```bash
net::interface::speed() {
    local iface="${1:-eth0}"
    if [[ -f "/sys/class/net/$iface/speed" ]]; then
        cat "/sys/class/net/$iface/speed" > /dev/null 2>&1 || echo "Unknown"
    fi
}
```

## Module

[`net`](../net.md)
