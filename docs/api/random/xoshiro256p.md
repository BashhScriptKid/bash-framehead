# `random::xoshiro256p`

**Signature:** `random::xoshiro256p(same, as, xoshiro256ss)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Xoshiro256+ — faster output, slightly weaker low bits

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `same` | string | Yes | |
| `as` | string | Yes | |
| `xoshiro256ss` | string | Yes | |

## Source

```bash
random::xoshiro256p() {
		local s0="$1" s1="$2" s2="$3" s3="$4"

		local result=$(( s0 + s3 ))
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

