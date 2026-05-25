# `runtime::distro`

**Signature:** `runtime::distro()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::distro() {
	if [[ -f /etc/os-release ]]; then
		(. /etc/os-release && echo "$ID")
	else
		echo "unknown"
	fi
}
```

