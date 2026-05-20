# `timedate::time::is_before`

Check if current time is before a given time

## Usage

```bash
timedate::time::is_before HH:MM
```

## Source

```bash
timedate::time::is_before() {
    local target="$1"
    local current
    current=$(date +%H:%M)
    [[ "$current" < "$target" ]]
}
```

## Module

[`timedate`](../timedate.md)
