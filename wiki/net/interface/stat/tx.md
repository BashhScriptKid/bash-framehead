# `net::interface::stat::tx`

_No description available._

## Source

```bash
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
```

## Module

[`net`](../net.md)
