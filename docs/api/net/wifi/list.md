# `net::wifi::list`

**Signature:** `net::wifi::list([ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- WIFI CONTROL ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ifname` | string | No | |

## Source

```bash
net::wifi::list() {
		_net::require_backend || return 1
		local ifname="${1:-}"
		case "$_NET_BACKEND" in
				nm)
						if [[ -n "$ifname" ]]; then
								nmcli -t -f SSID,SIGNAL,SECURITY,FREQ,CHAN,BARS \
										device wifi list ifname "$ifname" 2>/dev/null
						else
								nmcli -t -f SSID,SIGNAL,SECURITY,FREQ,CHAN,BARS \
										device wifi list 2>/dev/null
						fi
						;;
				ip)
						if [[ -z "$ifname" ]]; then
								for d in /sys/class/net/*/wireless; do
										[[ -d "$d" ]] && { ifname="${d%/wireless}"; ifname="${ifname##*/}"; break; }
								done
						fi
						[[ -z "$ifname" ]] && { echo "net::wifi::list: no wifi interface" >&2; return 1; }
						iw dev "$ifname" scan 2>/dev/null | \
								awk '
									/^BSS / { if (ssid != "") print ssid; ssid = "" }
									/^[[:space:]]+SSID:[[:space:]]?/ {
											sub(/^[[:space:]]+SSID:[[:space:]]?/, "")
											if ($0 != "") ssid = $0
									}
									END { if (ssid != "") print ssid }
								'
						;;
		esac
}
```

