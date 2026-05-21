# `timedate::tz::convert`

**Signature:** `timedate::tz::convert(timestamp, timezone)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Convert a timestamp to a different timezone

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `timestamp` | string | Yes | |
| `timezone` | string | Yes | |

## Example

```bash
timedate::tz::convert 1700000000 "America/New_York"
```

## Source

```bash
timedate::tz::convert() {
    local ts="$1" tz="$2"
    if _timedate::has_gnu_date; then
        TZ="$tz" date -d "@$ts" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    else
        TZ="$tz" date -r "$ts" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    fi
}
```

