# `net::interface::mac`

**Signature:** `net::interface::mac(<name>, <mac>, [persistent])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Set MAC address on an interface.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<mac>` | string | Yes | |
| `persistent` | string | No | |

## Source

```bash
net::interface::mac() {
		_net::require_backend || return 1
		local name="$1" mac="$2" persistent="${3:-}"
		[[ -z "$name" || -z "$mac" ]] && { echo "net::interface::mac: name and mac required" >&2; return 1; }
		if ! [[ "$mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
				echo "net::interface::mac: invalid format (expected xx:xx:xx:xx:xx:xx)" >&2
				return 1
		fi
		case "$_NET_BACKEND" in
				nm)
						if ! nmcli connection modify "$name" 802-3-ethernet.cloned-mac-address "$mac" 2>/dev/null; then
								nmcli connection modify "$name" wifi.cloned-mac-address "$mac"
						fi
						echo "net::interface::mac: takes effect on next reconnect" >&2
						;;
				ip)
						[[ "$persistent" == "yes" ]] && \
								echo "net::interface::mac: :persistent has no effect with ip backend" >&2
						ip link set "$name" address "$mac"
						;;
		esac
}
```

