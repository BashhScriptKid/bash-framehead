# `timedate::calendar::is_weekday`

**Signature:** `timedate::calendar::is_weekday(arg1)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a date falls on a weekday

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
timedate::calendar::is_weekday() {
		! timedate::calendar::is_weekend "$1"
}
```

