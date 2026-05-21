# `timedate::timestamp::to_human`

**Signature:** `timedate::timestamp::to_human(timestamp, [format])`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Convert unix timestamp to human-readable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `timestamp` | string | Yes | |
| `format` | string | No | |

## Source

```bash
timedate::timestamp::to_human() {
    local ts="$1" fmt="${2:-%Y-%m-%d %H:%M:%S}"
    _timedate::format "$fmt" "$ts"
}
```

