# `log::warn`

**Signature:** `log::warn(message)`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log a warning message

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `message` | string | Yes | |

## Example

```bash
Example:
```

## Source

```bash
log::warn() {
    _log::emit "WARN" $LOG_WARN "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}
```

