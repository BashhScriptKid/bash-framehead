# `timedate::tz::now`

**Signature:** `timedate::tz::now(timezone)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get current time in a specific timezone

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `timezone` | string | Yes | |

## Source

```bash
timedate::tz::now() {
    TZ="$1" date "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
}
```

