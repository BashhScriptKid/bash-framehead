# `runtime::execignore::list`

**Signature:** `runtime::execignore::list()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

List current EXECIGNORE patterns, one per line.


## Source

```bash
runtime::execignore::list() {
		if [[ -n "${EXECIGNORE:-}" ]]; then
				echo "${EXECIGNORE}" | tr ':' '\n'
		fi
}
```

