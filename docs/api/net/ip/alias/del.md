# `net::ip::alias::del`

**Signature:** `net::ip::alias::del(<ifname>, <cidr>)`

**Module:** [`net`](../../../net.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Remove a secondary IPv4 address from an interface.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<ifname>` | string | Yes | |
| `<cidr>` | string | Yes | |

## Source

```bash
net::ip::alias::del() {
		_net::require_backend || return 1
		local ifname="$1" cidr="$2"
		[[ -z "$ifname" || -z "$cidr" ]] && { echo "net::ip::alias::del: ifname and cidr required" >&2; return 1; }
		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						conn="${conn:-$ifname}"
						nmcli connection modify "$conn" -ipv4.addresses "$cidr"
						echo "net::ip::alias::del: takes effect on next reconnect" >&2
						;;
				ip)
						ip addr del "$cidr" dev "$ifname"
						;;
		esac
}
```

