# `runtime::recurselimit::set`

**Signature:** `runtime::recurselimit::set(50)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Set recursion limit to guard against infinite recursion.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `50` | string | Yes | |

## Source

```bash
runtime::recurselimit::set() {
		[[ -n "${1:-}" ]] || {
			echo "runtime::recurselimit::set: limit required" >&2
			return 1
		}
		FUNCNEST="$1"
}
```

