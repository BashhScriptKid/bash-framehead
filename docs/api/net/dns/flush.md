# `net::dns::flush`

**Signature:** `net::dns::flush()`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Flush DNS caches.


## Source

```bash
net::dns::flush() {
		_net::require_backend || return 1
		case "$_NET_BACKEND" in
				nm|ip)
						# Both backends ultimately use systemd-resolved when present
						# (NM resolves via it under systemd), and resolvectl flush-caches
						# is the canonical flush on modern systems.
						if runtime::has_command resolvectl; then
								resolvectl flush-caches
						elif runtime::has_command nscd; then
								nscd -i hosts
						else
								echo "net::dns::flush: no cache backend found (resolvectl/nscd)" >&2
								return 1
						fi
						;;
		esac
}
```

