# `runtime::recurselimit::get`

**Signature:** `runtime::recurselimit::get()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get current recursion limit (FUNCNEST). 0 = unlimited.


## Source

```bash
runtime::recurselimit::get() {
		echo "${FUNCNEST:-0}"
}
```

