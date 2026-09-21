# `net::interface::up`

**Signature:** `net::interface::up(<name>)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- INTERFACE CONTROL ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
net::interface::up() {
		_net::require_backend || return 1
		local name="$1"
		[[ -z "$name" ]] && { echo "net::interface::up: name required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						nmcli device connect "$name" 2>/dev/null || \
								ip link set "$name" up
						;;
				ip)
						ip link set "$name" up
						;;
		esac
}
```

