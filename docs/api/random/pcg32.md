# `random::pcg32`

**Signature:** `random::pcg32(state, inc)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

PCG32 (Permuted Congruential Generator)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `state` | string | Yes | |
| `inc` | string | Yes | |

## Source

```bash
random::pcg32() {
		local state="$1" inc="$2"

		local oldstate="$state"
		state=$(( oldstate * 6364136223846793005 + (inc | 1) ))

		local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
		local rot=$(( oldstate >> 59 ))
		local result
		result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

		echo "$result $state"
}
```

