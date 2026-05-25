# `net::is_online`

**Signature:** `net::is_online()`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code

## Description

!/usr/bin/env bash


## Source

```bash
net::is_online() {
		local endpoints=("8.8.8.8" "1.1.1.1" "9.9.9.9")
		for endpoint in "${endpoints[@]}"; do
				if ping -c 1 -W 2 "$endpoint" >/dev/null 2>&1; then
						return 0
				fi
		done
		return 1
}
```

