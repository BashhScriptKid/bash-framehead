# `net::interface::speed`

**Signature:** `net::interface::speed()`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

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

