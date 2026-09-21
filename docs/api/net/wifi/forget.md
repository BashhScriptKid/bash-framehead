# `net::wifi::forget`

**Signature:** `net::wifi::forget(<ssid-or-uuid>)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Forget a saved WiFi network (remove its connection profile).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<ssid-or-uuid>` | string | Yes | |

## Source

```bash
net::wifi::forget() {
		_net::require_backend || return 1
		local ident="$1"
		[[ -z "$ident" ]] && { echo "net::wifi::forget: ssid or uuid required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local uuid
						if [[ "$ident" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
								uuid="$ident"
						else
								uuid=$(nmcli -t -f NAME,UUID connection show 2>/dev/null | \
										awk -F: -v n="$ident" '$1 == n {print $2; exit}')
								if [[ -z "$uuid" ]]; then
										echo "net::wifi::forget: connection not found: $ident" >&2
										return 1
								fi
						fi
						nmcli connection delete uuid "$uuid"
						;;
				ip)
						echo "net::wifi::forget: ip backend does not support forget" >&2
						return 1
						;;
		esac
}
```

