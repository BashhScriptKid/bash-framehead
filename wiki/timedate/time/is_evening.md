# `timedate::time::is_evening`

Check if currently evening (18:00-23:59)

## Source

```bash
timedate::time::is_evening() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 18 ))
}
```

## Module

[`timedate`](../timedate.md)
