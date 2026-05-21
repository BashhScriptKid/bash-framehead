# `timedate::time::is_before`

**Signature:** `timedate::time::is_before(HH:MM)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if current time is before a given time

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `HH:MM` | string | Yes | |

## Source

```bash
timedate::time::is_before() {
    local target="$1"
    local current
    current=$(date +%H:%M)
    [[ "$current" < "$target" ]]
}
```

