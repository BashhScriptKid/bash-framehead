# `math::vec3::new`

**Signature:** `math::vec3::new()`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::vec2 ---


## Source

```bash
math::vec3::new() {
		local x="${1:-0}" y="${2:-0}"

		[[ "$x" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || x=0
		[[ "$y" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || y=0

		echo "${x},${y}"
}
```

