# `net::interface::stat::rx`

**Signature:** `net::interface::stat::rx()`

**Module:** [`net`](../../../net.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
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
```

