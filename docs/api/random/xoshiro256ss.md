# `random::xoshiro256ss`

**Signature:** `random::xoshiro256ss(s0, s1, s2, s3)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

XOSHIRO256** (star-star)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `s0` | string | Yes | |
| `s1` | string | Yes | |
| `s2` | string | Yes | |
| `s3` | string | Yes | |

## Source

```bash
random::xoshiro256ss() {
		local s0="$1" s1="$2" s2="$3" s3="$4"

		local result
		result=$(_random::rotl64 $(( s1 * 5 )) 7)
		result=$(( result * 9 ))
		local t=$(( s1 << 17 ))

		s2=$(( s2 ^ s0 ))
		s3=$(( s3 ^ s1 ))
		s1=$(( s1 ^ s2 ))
		s0=$(( s0 ^ s3 ))
		s2=$(( s2 ^ t ))
		s3=$(_random::rotl64 $s3 45)

		echo "$result $s0 $s1 $s2 $s3"
}
```

