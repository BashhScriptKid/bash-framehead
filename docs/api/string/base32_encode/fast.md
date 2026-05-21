# `string::base32_encode::fast`

**Signature:** `string::base32_encode::fast(result_var, str)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |

## Source

```bash
string::base32_encode::fast() {
    local -n _string_base32_encode_result="$1"
    if runtime::has_command base32; then
        _string_base32_encode_result=$(echo -n "$2" | base32)
    elif runtime::has_command gbase32; then
        _string_base32_encode_result=$(echo -n "$2" | gbase32)
    else
        echo "string::base32_encode::fast: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}
```

