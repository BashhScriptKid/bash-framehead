# `pfloat::fixed::factorial`

**Signature:** `pfloat::fixed::factorial(arg1)`

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
pfloat::fixed::factorial() {
	local n="$1"
	local result="1" i

	if [[ "$n" == -* ]]; then
		echo "pfloat::fixed::factorial: negative input" >&2
		return 1
	fi

	n=$(pfloat::fixed::trunc "$n")

	for ((i = 2; i <= n; i++)); do
		result=$(pfloat::fixed::mul "$result" "$i")
	done
	echo "$result"
}
```

