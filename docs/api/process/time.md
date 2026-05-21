# `process::time`

**Signature:** `process::time(command, [args...])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Run a command and return its execution time in seconds

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `command` | command | Yes | |
| `args...` | string | No | |

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

