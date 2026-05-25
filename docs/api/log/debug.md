# `log::debug`

**Signature:** `log::debug(message)`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- PUBLIC API ---

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
log::debug() {
		_log::emit "DEBUG" $LOG_DEBUG "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}
```

