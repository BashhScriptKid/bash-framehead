# `log::info`

**Signature:** `log::info(message)`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log an informational message

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
log::info() {
    _log::emit "INFO" $LOG_INFO "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}
```

