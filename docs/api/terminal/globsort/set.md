# `terminal::globsort::set`

**Signature:** `terminal::globsort::set(arg1)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

GLOBSORT

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
terminal::globsort::set() {
		[[ -n "${1:-}" ]] || { echo "terminal::globsort::set: value required" >&2; return 1; }
		_runtime::min_bash 5.3 || return 1
		GLOBSORT="$1"
}
```

