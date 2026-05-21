# `string::base64_encode::fast`

**Signature:** `string::base64_encode::fast(result_var, str)`

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
string::base64_encode::fast() {
    local -n _string_base64_encode_result="$1"
    case "$(runtime::os)" in
    darwin) _string_base64_encode_result=$(echo -n "$2" | base64) ;;
    *)      _string_base64_encode_result=$(echo -n "$2" | base64 -w 0) ;;
    esac
}
```

