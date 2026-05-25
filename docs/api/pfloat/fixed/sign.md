# `pfloat::fixed::sign`

**Signature:** `pfloat::fixed::sign(arg1)`

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
pfloat::fixed::sign() {
	local a="$1"
	if pfloat::fixed::is_negative "$a"; then
		echo "-1"
	elif pfloat::fixed::is_positive "$a"; then
		echo "1"
	else
		echo "0"
	fi
}
```

