# `timedate::has_gnu_date`

**Signature:** `timedate::has_gnu_date(&&, echo, GNU, date)`

**Module:** [`timedate`](../timedate.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Public: check if GNU date is available

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `&&` | string | Yes | |
| `echo` | string | Yes | |
| `GNU` | string | Yes | |
| `date` | string | Yes | |

## Source

```bash
timedate::has_gnu_date() {
		_timedate::has_gnu_date
}
```

