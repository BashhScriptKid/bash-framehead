# `math::product`

**Signature:** `math::product()`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Product of a sequence of integers


## Source

```bash
math::product() {
		local result=1
		for n in "$@"; do
				_math::is_float "$n" && { echo "math::product: float input — use math::productf" >&2; return 1; }
				(( result *= n ))
		done
		echo "$result"
}
```

