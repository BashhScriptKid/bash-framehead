# `string::base32_decode`

**Signature:** `string::base32_decode(arg1)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
string::base32_decode() {
    local input; _string::read_input input "$@"
    if runtime::has_command base32; then
        echo -n "$input" | base32 --decode
    elif runtime::has_command gbase32; then
        echo -n "$1" | gbase32 --decode
    else
        echo "string::base32_decode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}
```

