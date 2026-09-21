# `runtime::coproc::list`

**Signature:** `runtime::coproc::list(<registry>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

List active tracked coprocs.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<registry>` | string | Yes | |

## Source

```bash
runtime::coproc::list() {
		local -n _registry="$1"
		local name
		for name in "${_registry[@]}"; do
				local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null)
				local alive="dead"
				runtime::coproc::alive "$name" 2>/dev/null && alive="alive"
				echo "$name pid=$pid $alive"
		done
}
```

