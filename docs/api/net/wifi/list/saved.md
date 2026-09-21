# `net::wifi::list::saved`

**Signature:** `net::wifi::list::saved()`

**Module:** [`net`](../../../net.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List saved/known wifi connection profiles.


## Source

```bash
net::wifi::list::saved() {
		_net::require_backend || return 1
		case "$_NET_BACKEND" in
				nm)
						nmcli -t -f NAME,TYPE connection show 2>/dev/null | \
								awk -F: '$2 == "802-11-wireless" || $2 == "wifi" {print $1}'
						;;
				ip)
						# Best-effort: scan common wpa_supplicant config locations.
						local conf
						for conf in /etc/wpa_supplicant/wpa_supplicant.conf \
								/etc/wpa_supplicant.conf \
								"$HOME/.config/wpa_supplicant/wpa_supplicant.conf"; do
								[[ -r "$conf" ]] && { \
										awk -F'"' '/^[[:space:]]*ssid=/{print $2}' "$conf"; \
										return; \
								}
						done
						;;
		esac
}
```

