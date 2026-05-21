# `terminal::read_key::timeout`

**Signature:** `terminal::read_key::timeout(varname, seconds)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Read a single keypress with a timeout

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |
| `seconds` | string | Yes | |

## Source

```bash
terminal::read_key::timeout() {
    local _var="${1:-_TERMINAL_KEY}" _timeout="${2:-5}"
    local _key
    IFS= read -r -s -n1 -t "$_timeout" _key
    printf -v "$_var" '%s' "$_key"
}
```

