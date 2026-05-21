# `timedate::time::is_between`

**Signature:** `timedate::time::is_between(HH:MM, HH:MM)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if current time is between two times (HH:MM)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `HH:MM` | string | Yes | |
| `HH:MM` | string | Yes | |

## Source

```bash
timedate::time::is_between() {
    local start="$1" end="$2"
    local current
    current=$(date +%H:%M)
    [[ "$current" > "$start" && "$current" < "$end" ]]
}
```

