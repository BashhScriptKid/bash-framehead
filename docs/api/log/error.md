# `log::error`

**Signature:** `log::error(message, [exit_code])`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log an error message, optionally exiting with a given code

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `message` | string | Yes | |
| `exit_code` | integer | No | |

## Example

```bash
Example:
```

## Source

```bash
log::error() {
    local msg="$1"
    local exit_code="${2:-}"
    _log::emit "ERROR" $LOG_ERROR "$msg" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
    if [[ -n "$exit_code" && "$exit_code" =~ ^-?[0-9]+$ ]]; then
        exit "$exit_code"
    fi
}
```

