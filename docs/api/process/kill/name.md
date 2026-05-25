# `process::kill::name`

**Signature:** `process::kill::name(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Kill all processes matching a name

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::kill::name() {
		pkill -x "$1" 2>/dev/null
}
```

