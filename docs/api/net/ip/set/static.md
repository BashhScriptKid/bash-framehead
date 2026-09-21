# `net::ip::set::static`

**Signature:** `net::ip::set::static(<ifname>, <cidr>, [gw], [dns]...)`

**Module:** [`net`](../../../net.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Configure a static IPv4 address on an interface. Replaces the existing

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<ifname>` | string | Yes | |
| `<cidr>` | string | Yes | |
| `gw` | string | No | |
| `[dns]...` | string | — | |

## Source

```bash
net::ip::set::static() {
		_net::require_backend || return 1
		local ifname="$1" cidr="$2" gw="${3:-}"
		shift 3 2>/dev/null || shift $#
		[[ -z "$ifname" || -z "$cidr" ]] && { echo "net::ip::set::static: ifname and cidr required" >&2; return 1; }
		_net::_ip_valid_cidr "$cidr" || { echo "net::ip::set::static: invalid cidr: $cidr" >&2; return 1; }
		if [[ -n "$gw" ]]; then
				net::ip::is_valid_v4 "$gw" || { echo "net::ip::set::static: invalid gateway: $gw" >&2; return 1; }
		fi

		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						conn="${conn:-$ifname}"
						local args=(connection modify "$conn" ipv4.method manual ipv4.addresses "$cidr")
						[[ -n "$gw" ]] && args+=(ipv4.gateway "$gw")
						local dns_count=0
						for dns in "$@"; do
								args+=(ipv4.dns "$dns")
								(( dns_count++ ))
						done
						(( dns_count > 0 )) && args+=(ipv4.ignore-auto-dns yes)
						nmcli "${args[@]}"
						echo "net::ip::set::static: takes effect on next reconnect" >&2
						;;
				ip)
						[[ -z "$gw" ]] && { echo "net::ip::set::static: gateway required with ip backend" >&2; return 1; }
						# Destructive: flushes all addresses on the device. The
						# new config must come up correctly or connectivity is lost.
						ip addr flush dev "$ifname" 2>/dev/null
						ip addr add "$cidr" dev "$ifname"
						ip route add default via "$gw" dev "$ifname" 2>/dev/null
						for dns in "$@"; do
								resolvectl dns "$ifname" "$dns"
						done
						;;
		esac
}
```

