# `net::wifi::connect`

**Signature:** `net::wifi::connect(<ssid>, [password], [ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Connect to a WiFi network. For WPA2-Personal / open networks only.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<ssid>` | string | Yes | |
| `password` | string | No | |
| `ifname` | string | No | |

## Source

```bash
net::wifi::connect() {
		_net::require_backend || return 1
		local ssid="$1" password="${2:-}" ifname="${3:-}"
		[[ -z "$ssid" ]] && { echo "net::wifi::connect: ssid required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local args=(device wifi connect "$ssid")
						[[ -n "$password" ]] && args+=(password "$password")
						[[ -n "$ifname" ]] && args+=(ifname "$ifname")
						nmcli "${args[@]}"
						;;
				ip)
						echo "net::wifi::connect: ip backend does not support wifi connect; use nm" >&2
						return 1
						;;
		esac
}
```

