# `fs::watch`

Watch a file for changes, run callback on change

## Usage

```bash
fs::watch path callback [interval_seconds]
```
Callback receives the path as $1

## Source

```bash
fs::watch() {
    local path="$1" callback="$2" interval="${3:-1}"
    local last_modified
    last_modified=$(fs::modified "$path")

    while true; do
        sleep "$interval"
        local current
        current=$(fs::modified "$path")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$callback" "$path"
        fi
    done
}
```

## Module

[`fs`](../fs.md)
