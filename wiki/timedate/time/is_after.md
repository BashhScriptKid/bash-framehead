# `timedate::time::is_after`

Check if current time is after a given time

## Source

```bash
timedate::time::is_after() {
    local target="$1"
    local current
    current=$(date +%H:%M)
    [[ "$current" > "$target" ]]
}
```

## Module

[`timedate`](../timedate.md)
