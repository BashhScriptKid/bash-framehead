# `timedate::duration::format_ms`

Format milliseconds into human-readable duration

## Source

```bash
timedate::duration::format_ms() {
    local ms="$1"
    if (( ms < 1000 )); then
        echo "${ms}ms"
    elif (( ms < 60000 )); then
        echo "$(( ms / 1000 ))s $(( ms % 1000 ))ms"
    else
        timedate::duration::format "$(( ms / 1000 ))"
    fi
}
```

## Module

[`timedate`](../timedate.md)
