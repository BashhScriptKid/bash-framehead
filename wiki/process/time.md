# `process::time`

Run a command and return its execution time in seconds

## Usage

```bash
process::time command [args...]
```

## Source

```bash
process::time() {
    local start end
    start=$(date +%s%N 2>/dev/null || date +%s)
    "$@"
    local ret=$?
    end=$(date +%s%N 2>/dev/null || date +%s)
    # nanosecond precision if available
    if [[ "${#start}" -gt 10 ]]; then
        echo "$(( (end - start) / 1000000 ))ms"
    else
        echo "$(( end - start ))s"
    fi
    return $ret
}
```

## Module

[`process`](../process.md)
