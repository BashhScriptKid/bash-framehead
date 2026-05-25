# `process::memory::percent`

**Signature:** `process::memory::percent(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get memory usage as percentage

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::memory::percent() {
		ps -o pmem= -p "$1" 2>/dev/null | tr -d ' '
}
```

