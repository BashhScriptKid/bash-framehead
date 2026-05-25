# `runtime::bash_version::major`

**Signature:** `runtime::bash_version::major()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::bash_version::major() {
	echo "${BASH_VERSINFO[0]}"
}
```

