# `timedate::time::is_morning`

**Signature:** `timedate::time::is_morning()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if currently morning (00:00-11:59)


## Source

```bash
timedate::time::is_morning() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour < 12 ))
}
```

