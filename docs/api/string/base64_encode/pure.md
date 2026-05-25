# `string::base64_encode::pure`

**Signature:** `string::base64_encode::pure()`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
string::base64_encode::pure() {
		local input; _string::read_input input "$@"
		local _str="$input" out="" i a b c
		local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

		for (( i=0; i<${#s}; i+=3 )); do
				a=$(printf '%d' "'${_str:$i:1}")
				b=$(( i+1 < ${#s} ? $(printf '%d' "'${_str:$((i+1)):1}") : 0 ))
				c=$(( i+2 < ${#s} ? $(printf '%d' "'${_str:$((i+2)):1}") : 0 ))

				out+="${_B64:$(( (a >> 2) & 63 )):1}"
				out+="${_B64:$(( ((a << 4) | (b >> 4)) & 63 )):1}"
				out+="${_B64:$(( i+1 < ${#s} ? ((b << 2) | (c >> 6)) & 63 : 64 )):1}"
				out+="${_B64:$(( i+2 < ${#s} ? c & 63 : 64 )):1}"
		done

		echo "$out"
}
```

