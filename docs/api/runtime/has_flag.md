# `runtime::has_flag`

**Signature:** `runtime::has_flag(arg1)`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
runtime::has_flag() {
    local flag="$1"
    [[ "$-" == *"$flag"* ]]
}
```

