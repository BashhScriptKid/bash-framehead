# `net::wifi::disconnect`

**Signature:** `net::wifi::disconnect([ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Disconnect from the current WiFi network. With nm, this is non-persistent

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ifname` | string | No | |

## Source

```bash
net::wifi::disconnect() {
		_net::require_backend || return 1
		local ifname="${1:-}"
		case "$_NET_BACKEND" in
				nm)
						if [[ -n "$ifname" ]]; then
								nmcli device disconnect "$ifname"
						else
								nmcli -t -f DEVICE,TYPE device status 2>/dev/null | \
										awk -F: '$2 == "wifi" {print $1}' | \
										while read -r dev; do
										[[ -n "$dev" ]] && nmcli device disconnect "$dev"
								done
						fi
						;;
				ip)
						if [[ -z "$ifname" ]]; then
								for d in /sys/class/net/*/wireless; do
										[[ -d "$d" ]] && { ifname="${d%/wireless}"; ifname="${ifname##*/}"; break; }
								done
						fi
						[[ -z "$ifname" ]] && { echo "net::wifi::disconnect: no wifi interface" >&2; return 1; }
						iw dev "$ifname" disconnect
						;;
		esac
}
```

