# `timedate::time::is_between`

Check if current time is between two times (HH:MM)

## Usage

```bash
timedate::time::is_between HH:MM HH:MM
```

## Source

```bash
timedate::time::is_between() {
    local start="$1" end="$2"
    local current
    current=$(date +%H:%M)
    [[ "$current" > "$start" && "$current" < "$end" ]]
}
```

## Module

[`timedate`](../timedate.md)
