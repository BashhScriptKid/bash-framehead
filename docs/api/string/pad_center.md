# `string::pad_center`

**Signature:** `string::pad_center(str, width, [char])`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Centre a string within a given width

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `width` | string | Yes | |
| `char` | string | No | |

## Source

```bash
string::pad_center() {
	local input width char
	if [[ $# -ge 2 ]]; then
		input="$1"; width="$2"; char="${3:- }"
	else
		input=$(cat); width="$1"; char="${2:- }"
	fi
	local len="${#input}"
	if ((len >= width)); then echo "$input"; return; fi
	local total=$((width - len))
	local left=$((total / 2))
	local right=$((total - left))
	local lpad rpad
	lpad=$(string::repeat "$char" $left)
	rpad=$(string::repeat "$char" $right)
	echo "${lpad}${input}${rpad}"
}
```

