# `pfloat::fixed::trunc`

**Signature:** `pfloat::fixed::trunc(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::trunc() {
	local a="$1"

	if [[ "$a" == *.* ]]; then
		a="${a%%.*}"
	fi

	[[ -z "$a" ]] && a="0"
	echo "$a"
}
```

