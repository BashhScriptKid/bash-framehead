# `net::ip::set::dhcp`

**Signature:** `net::ip::set::dhcp(<ifname>)`

**Module:** [`net`](../../../net.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Switch an interface to DHCP (auto) addressing.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<ifname>` | string | Yes | |

## Source

```bash
net::ip::set::dhcp() {
		_net::require_backend || return 1
		local ifname="$1"
		[[ -z "$ifname" ]] && { echo "net::ip::set::dhcp: ifname required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						conn="${conn:-$ifname}"
						nmcli connection modify "$conn" \
								ipv4.method auto \
								ipv4.addresses "" \
								ipv4.gateway "" \
								ipv4.dns "" ipv4.ignore-auto-dns no
						echo "net::ip::set::dhcp: takes effect on next reconnect" >&2
						;;
				ip)
						if ! runtime::has_command dhclient && ! runtime::has_command dhcpcd; then
								echo "net::ip::set::dhcp: no DHCP client (need dhclient or dhcpcd)" >&2
								return 1
						fi
						ip addr flush dev "$ifname" 2>/dev/null
						if runtime::has_command dhclient; then
								dhclient "$ifname"
						else
								dhcpcd "$ifname"
						fi
						resolvectl revert "$ifname" 2>/dev/null
						;;
		esac
}
```

