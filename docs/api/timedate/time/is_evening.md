# `timedate::time::is_evening`

**Signature:** `timedate::time::is_evening()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if currently evening (18:00-23:59)


## Source

```bash
timedate::time::is_evening() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 18 ))
}
```

