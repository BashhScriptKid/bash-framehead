# `string::base64_decode::fast`

**Signature:** `string::base64_decode::fast(result_var, str)`

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
string::base64_decode::fast() {
		local -n _string_base64_decode_result="$1"
		case "$(runtime::os)" in
		darwin) _string_base64_decode_result=$(echo -n "$2" | base64 -D) ;;
		*)      _string_base64_decode_result=$(echo -n "$2" | base64 --decode) ;;
		esac
}
```

