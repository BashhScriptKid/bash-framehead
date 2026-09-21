# `net::interface::mtu`

**Signature:** `net::interface::mtu(<name>, <mtu>)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Set MTU on an interface.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<mtu>` | string | Yes | |

## Source

```bash
net::interface::mtu() {
		_net::require_backend || return 1
		local name="$1" mtu="$2"
		[[ -z "$name" || -z "$mtu" ]] && { echo "net::interface::mtu: name and mtu required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						if ! nmcli connection modify "$name" 802-3-ethernet.mtu "$mtu" 2>/dev/null; then
								nmcli connection modify "$name" wifi.mtu "$mtu"
						fi
						;;
				ip)
						ip link set "$name" mtu "$mtu"
						;;
		esac
}
```

