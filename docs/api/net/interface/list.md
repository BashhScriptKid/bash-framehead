# `net::interface::list`

**Signature:** `net::interface::list(arg2)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- NETWORK INTERFACES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
net::interface::list() {
		if runtime::has_command ip; then
				ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/{print $2}' | tr -d ' '
		elif runtime::has_command ifconfig; then
				ifconfig -l 2>/dev/null | tr ' ' '\n'
		elif [[ -d /sys/class/net ]]; then
				ls /sys/class/net/
		fi
}
```

