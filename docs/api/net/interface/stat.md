# `net::interface::stat`

**Signature:** `net::interface::stat(s, interface)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get network interface statistics (rx/tx bytes)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `s` | string | Yes | |
| `interface` | string | Yes | |

## Source

```bash
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
```

