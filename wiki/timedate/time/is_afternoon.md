# `timedate::time::is_afternoon`

Check if currently afternoon (12:00-17:59)

## Source

```bash
timedate::time::is_afternoon() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 12 && hour < 18 ))
}
```

## Module

[`timedate`](../timedate.md)
