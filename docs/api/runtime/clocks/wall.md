# `runtime::clocks::wall`

**Signature:** `runtime::clocks::wall(ts=$(runtime::clocks::wall))`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Wall clock — seconds since epoch with microsecond precision.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ts=$(runtime::clocks::wall)` | string | Yes | |

## Source

```bash
runtime::clocks::wall() {
		runtime::features::has epoch_realtime || return 1
		echo "${EPOCHREALTIME:-0}"
}
```

