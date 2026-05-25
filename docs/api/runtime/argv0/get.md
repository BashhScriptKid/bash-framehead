# `runtime::argv0::get`

**Signature:** `runtime::argv0::get()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get $0 (script name). Uses BASH_ARGV0 when available (Bash 5.0+).


## Source

```bash
runtime::argv0::get() {
		echo "${BASH_ARGV0:-$0}"
}
```

