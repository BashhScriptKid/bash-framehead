# `string::url_encode::fast`

**Signature:** `string::url_encode::fast(result_var, str)`

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
string::url_encode::fast() {
		local -n _string_url_encode_result="$1"
		local _str="$2" encoded="" i char hex
		for (( i=0; i<${#s}; i++ )); do
				char="${_str:$i:1}"
				case "$char" in
						[a-zA-Z0-9.~_-]) encoded+="$char" ;;
						*) printf -v hex '%02X' "'$char"
							 encoded+="%$hex" ;;
				esac
		done
		_string_url_encode_result="$encoded"
}
```

