# `net::dns::set`

**Signature:** `net::dns::set(<server>..., [ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Replace all DNS servers on an interface.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<server>...` | string | — | |
| `ifname` | string | No | |

## Source

```bash
net::dns::set() {
		_net::require_backend || return 1
		(($# == 0)) && { echo "net::dns::set: at least one server required" >&2; return 1; }

		# Resolve ifname: explicit (last arg = real interface) or default route.
		local ifname=""
		local last="${!#}"
		for d in /sys/class/net/*/; do
				local name="${d%/}"; name="${name##*/}"
				if [[ "$name" == "$last" ]]; then
						ifname="$name"
						break
				fi
		done

		local -a servers=()
		if [[ -n "$ifname" ]]; then
				(($# >= 2)) && servers=("${@:1:$#-1}") || servers=()
		else
				servers=("$@")
				ifname=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')
				[[ -z "$ifname" ]] && { echo "net::dns::set: cannot determine interface; pass an ifname" >&2; return 1; }
		fi

		((${#servers[@]} == 0)) && { echo "net::dns::set: at least one server required" >&2; return 1; }

		# Partition servers into IPv4 and IPv6 lists so the right nm field is set.
		local -a v4=() v6=()
		for s in "${servers[@]}"; do
				if [[ "$s" == *:* ]]; then
						v6+=("$s")
				else
						v4+=("$s")
				fi
		done

		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						if [[ -z "$conn" ]]; then
								echo "net::dns::set: no active connection on $ifname" >&2
								return 1
						fi
						((${#v4[@]} > 0)) && nmcli connection modify "$conn" \
								ipv4.dns "${v4[*]}" ipv4.ignore-auto-dns yes
						((${#v6[@]} > 0)) && nmcli connection modify "$conn" \
								ipv6.dns "${v6[*]}" ipv6.ignore-auto-dns yes
						echo "net::dns::set: takes effect on next reconnect" >&2
						;;
				ip)
						resolvectl dns "$ifname" "${servers[@]}"
						;;
		esac
}
```

