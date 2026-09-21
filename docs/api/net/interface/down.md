# `net::interface::down`

**Signature:** `net::interface::down(<name>)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Bring a network interface down. Non-persistent with nm (the autoconnect

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
net::interface::down() {
		_net::require_backend || return 1
		local name="$1"
		[[ -z "$name" ]] && { echo "net::interface::down: name required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						nmcli device disconnect "$name"
						;;
				ip)
						ip link set "$name" down
						;;
		esac
}
```

