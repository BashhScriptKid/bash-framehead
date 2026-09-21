# `net::dns::add`

**Signature:** `net::dns::add(<server>, [ifname])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Append a DNS server to the active set. Idempotent (skips duplicates).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<server>` | string | Yes | |
| `ifname` | string | No | |

## Source

```bash
net::dns::add() {
		_net::require_backend || return 1
		local new_server="$1"; shift
		[[ -z "$new_server" ]] && { echo "net::dns::add: server required" >&2; return 1; }

		# Resolve ifname (same heuristic as set).
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
		[[ -z "$ifname" ]] && { echo "net::dns::add: cannot determine interface" >&2; return 1; }

		# Read current servers into an array.
		local -a current=()
		case "$_NET_BACKEND" in
				nm)
						local conn
						conn=$(_net::_dns_nm_conn "$ifname")
						if [[ -z "$conn" ]]; then
								echo "net::dns::add: no active connection on $ifname" >&2
								return 1
						fi
						local dns
						dns=$(nmcli -t -f ipv4.dns connection show "$conn" 2>/dev/null | head -1)
						[[ -n "$dns" ]] && IFS=',' read -ra current <<< "$dns"
						;;
				ip)
						local line
						line=$(resolvectl dns "$ifname" 2>/dev/null | \
								awk '/^[[:space:]]*DNS[[:space:]]+Servers:[[:space:]]*/ {sub(/^[^:]*:[[:space:]]*/,""); print; exit}')
						[[ -n "$line" ]] && read -ra current <<< "$line"
						;;
		esac

		# Append new server if not already present.
		local already=0
		for s in "${current[@]}"; do
				[[ "$s" == "$new_server" ]] && already=1
		done
		(( already )) || current+=("$new_server")

		# Delegate to set with the merged list and explicit ifname.
		net::dns::set "${current[@]}" "$ifname"
}
```

