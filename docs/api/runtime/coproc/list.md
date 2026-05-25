# `runtime::coproc::list`

**Signature:** `runtime::coproc::list()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

List active tracked coprocs.


## Source

```bash
runtime::coproc::list() {
		local name
		for name in "${_RUNTIME_COPROCS[@]}"; do
				local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null)
				local alive="dead"
				runtime::coproc::alive "$name" 2>/dev/null && alive="alive"
				echo "$name pid=$pid $alive"
		done
}
```

