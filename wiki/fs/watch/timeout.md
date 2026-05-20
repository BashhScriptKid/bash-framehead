# `fs::watch::timeout`

Watch with a timeout (seconds)

## Usage

```bash
fs::watch::timeout path callback timeout [interval]
```

## Source

```bash
fs::watch::timeout() {
    local path="$1" callback="$2" timeout="$3" interval="${4:-1}"
    local elapsed=0
    local last_modified
    last_modified=$(fs::modified "$path")

    while (( elapsed < timeout )); do
        sleep "$interval"
        (( elapsed += interval ))
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
