# `string::pad_right`

**Signature:** `string::pad_right(str, width, [char])`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Pad string on the right to a given width

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `width` | string | Yes | |
| `char` | string | No | |

## Source

```bash
string::pad_right() {
	local input width char
	if [[ $# -ge 2 ]]; then
		input="$1"; width="$2"; char="${3:- }"
	else
		input=$(cat); width="$1"; char="${2:- }"
	fi
	local len="${#input}"
	if ((len >= width)); then echo "$input"; return; fi
	local pad
	pad=$(string::repeat "$char" $((width - len)))
	echo "${input}${pad}"
}
```

