# `net::ip::all`

**Signature:** `net::ip::all(arg2)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get all local IP addresses (one per line)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
net::ip::all() {
		if runtime::has_command ip; then
				ip addr show 2>/dev/null | awk '/inet /{gsub(/\/.*/, "", $2); print $2}'
		elif runtime::has_command ifconfig; then
				ifconfig 2>/dev/null | awk '/inet /{print $2}'
		fi
}
```

