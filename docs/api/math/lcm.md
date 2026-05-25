# `math::lcm`

**Signature:** `math::lcm(a, b)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Least common multiple

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::lcm() {
		local a="$1" b="$2"
		_math::is_float "$a" || _math::is_float "$b" && { echo "math::lcm: float input — lcm is integer-only" >&2; return 1; }
		local gcd
		gcd=$(math::gcd "$a" "$b")
		echo $(( (a / gcd) * b ))
}
```

