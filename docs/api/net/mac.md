# `net::mac`

**Signature:** `net::mac(interface)`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get MAC address of an interface

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `interface` | string | Yes | |

## Source

```bash
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
```

