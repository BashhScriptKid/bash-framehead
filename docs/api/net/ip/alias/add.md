# `net::ip::alias::add`

**Signature:** `net::ip::alias::add(<ifname>, <cidr>)`

**Module:** [`net`](../../../net.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Add a secondary IPv4 address to an interface.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<ifname>` | string | Yes | |
| `<cidr>` | string | Yes | |

## Source

```bash
net::ip::alias::add() {
		_net::require_backend || return 1
		local ifname="$1" cidr="$2"
		[[ -z "$ifname" || -z "$cidr" ]] && { echo "net::ip::alias::add: ifname and cidr required" >&2; return 1; }
		_net::_ip_valid_cidr "$cidr" || { echo "net::ip::alias::add: invalid cidr: $cidr" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						conn="${conn:-$ifname}"
						nmcli connection modify "$conn" +ipv4.addresses "$cidr"
						echo "net::ip::alias::add: takes effect on next reconnect" >&2
						;;
				ip)
						ip addr add "$cidr" dev "$ifname"
						;;
		esac
}
```

