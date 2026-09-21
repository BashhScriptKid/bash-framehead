# `net::dns::reset`

**Signature:** `net::dns::reset([ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Reset DNS to DHCP-controlled (remove manual servers, allow auto-DNS).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ifname` | string | No | |

## Source

```bash
net::dns::reset() {
		_net::require_backend || return 1
		local ifname=""
		if (($# > 0)); then
				local last="$1"
				for d in /sys/class/net/*/; do
						local name="${d%/}"; name="${name##*/}"
						if [[ "$name" == "$last" ]]; then
								ifname="$name"
								break
						fi
				done
		fi
		[[ -z "$ifname" ]] && ifname=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')
		[[ -z "$ifname" ]] && { echo "net::dns::reset: cannot determine interface" >&2; return 1; }

		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						if [[ -z "$conn" ]]; then
								echo "net::dns::reset: no active connection on $ifname" >&2
								return 1
						fi
						nmcli connection modify "$conn" \
								ipv4.dns "" ipv4.ignore-auto-dns no \
								ipv6.dns "" ipv6.ignore-auto-dns no
						echo "net::dns::reset: takes effect on next reconnect" >&2
						;;
				ip)
						resolvectl revert "$ifname"
						;;
		esac
}
```

