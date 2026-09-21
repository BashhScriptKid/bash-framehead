# `net::wifi::status`

**Signature:** `net::wifi::status([ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Show current WiFi connection status.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ifname` | string | No | |

## Source

```bash
net::wifi::status() {
		_net::require_backend || return 1
		local ifname="${1:-}"
		case "$_NET_BACKEND" in
				nm)
						if [[ -n "$ifname" ]]; then
								nmcli -t -f ACTIVE,SSID,BSSID,CHAN,FREQ,SIGNAL,SECURITY \
										device show "$ifname" 2>/dev/null
						else
								nmcli -t -f NAME,STATE,DEVICE connection show --active 2>/dev/null
						fi
						;;
				ip)
						if [[ -z "$ifname" ]]; then
								for d in /sys/class/net/*/wireless; do
										[[ -d "$d" ]] && { ifname="${d%/wireless}"; ifname="${ifname##*/}"; break; }
								done
						fi
						[[ -z "$ifname" ]] && { echo "net::wifi::status: no wifi interface" >&2; return 1; }
						iw dev "$ifname" link
						;;
		esac
}
```

