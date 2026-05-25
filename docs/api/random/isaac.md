# `random::isaac`

**Signature:** `random::isaac(a, b, c, s0..s7)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns: "result new_a new_b new_c s0..s7"

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `a` | string | Yes | |
| `b` | string | Yes | |
| `c` | string | Yes | |
| `s0..s7` | string | Yes | |

## Source

```bash
random::isaac() {
		local a="$1" b="$2" c="$3"; shift 3
		local -a s=("$@")

		c=$(( c + 1 ))
		b=$(( b + c ))
		a=$(( (a ^ (a << 13)) & 0xFFFFFFFF ))
		local x="${s[0]}"
		a=$(( (a + s[4]) & 0xFFFFFFFF ))
		local y=$(( (x + a + b) & 0xFFFFFFFF ))
		s[0]=$(( (y ^ (y >> 13)) & 0xFFFFFFFF ))
		b=$(( (s[0] + x) & 0xFFFFFFFF ))
		local result="$b"

		# Rotate state
		local tmp="${s[0]}"
		for (( i=0; i<7; i++ )); do s[$i]="${s[$((i+1))]}"; done
		s[7]="$tmp"

		echo "$result $a $b $c ${s[*]}"
}
```

