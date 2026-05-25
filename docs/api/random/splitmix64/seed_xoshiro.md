# `random::splitmix64::seed_xoshiro`

**Signature:** `random::splitmix64::seed_xoshiro(seed)`

**Module:** [`random`](../../random.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Expand a single 64-bit seed into four words for xoshiro256 initialisation

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seed` | string | Yes | |

## Source

```bash
random::splitmix64::seed_xoshiro() {
		local seed="$1" val state s0 s1 s2 s3
		state="$seed"
		read -r val state <<< "$(random::splitmix64 $state)"; s0="$val"
		read -r val state <<< "$(random::splitmix64 $state)"; s1="$val"
		read -r val state <<< "$(random::splitmix64 $state)"; s2="$val"
		read -r val state <<< "$(random::splitmix64 $state)"; s3="$val"
		echo "$s0 $s1 $s2 $s3"
}
```

