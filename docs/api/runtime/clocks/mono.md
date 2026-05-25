# `runtime::clocks::mono`

**Signature:** `runtime::clocks::mono(t0=$(runtime::clocks::mono))`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

CLOCKS

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `t0=$(runtime::clocks::mono)` | string | Yes | |

## Source

```bash
runtime::clocks::mono() {
		_runtime::min_bash 5.3 || return 1
		echo "${BASH_MONOSECONDS:-0}"
}
```

