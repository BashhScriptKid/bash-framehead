# `log::fatal`

**Signature:** `log::fatal(message, [exit_code])`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log an error and always exit, defaulting to exit code 1

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
log::fatal() {
    log::error "$1" "${2:-1}"
}
```

