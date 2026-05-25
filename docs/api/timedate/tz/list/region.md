# `timedate::tz::list::region`

**Signature:** `timedate::tz::list::region(America)`

**Module:** [`timedate`](../../../timedate.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List timezones filtered by region

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `America` | string | Yes | |

## Source

```bash
timedate::tz::list::region() {
		timedate::tz::list | grep "^${1}/"
}
```

