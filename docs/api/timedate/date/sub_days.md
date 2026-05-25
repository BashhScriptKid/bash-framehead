# `timedate::date::sub_days`

**Signature:** `timedate::date::sub_days(arg1, arg2)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Subtract n days from a date

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
timedate::date::sub_days() {
		timedate::date::add_days "$1" "$(( -$2 ))"
}
```

