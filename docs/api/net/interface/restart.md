# `net::interface::restart`

**Signature:** `net::interface::restart(<name>)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Restart a network interface (bounce it). Drops the link, sleeps 1s, brings

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
net::interface::restart() {
		_net::require_backend || return 1
		local name="$1"
		[[ -z "$name" ]] && { echo "net::interface::restart: name required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						nmcli device disconnect "$name" 2>/dev/null
						runtime::sleep 1
						nmcli device connect "$name" 2>/dev/null || \
								nmcli connection up "$name"
						;;
				ip)
						ip link set "$name" down
						runtime::sleep 1
						ip link set "$name" up
						;;
		esac
}
```

