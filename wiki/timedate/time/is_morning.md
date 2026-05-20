# `timedate::time::is_morning`

Check if currently morning (00:00-11:59)

## Source

```bash
timedate::time::is_morning() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour < 12 ))
}
```

## Module

[`timedate`](../timedate.md)
