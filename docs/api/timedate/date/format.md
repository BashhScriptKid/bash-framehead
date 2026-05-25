# `timedate::date::format`

**Signature:** `timedate::date::format([format], [timestamp])`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Current date in a custom format

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `format` | string | No | |
| `timestamp` | string | No | |

## Source

```bash
timedate::date::format() {
		local fmt="${1:-%Y-%m-%d}" _timestamp="${2:-}"
		_timedate::format "$fmt" "$_timestamp"
}
```

