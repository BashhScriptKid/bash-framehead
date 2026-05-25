# `random::well512::init`

**Signature:** `random::well512::init(seed)`

**Module:** [`random`](../../random.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

WELL512 (Well Equidistributed Long-period Linear)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seed` | string | Yes | |

## Source

```bash
random::well512::init() {
		local seed="$1" val state
		state="$seed"
		local -a words=()
		for (( i=0; i<16; i++ )); do
				read -r val state <<< "$(random::splitmix64 $state)"
				words+=( "$(_random::mask32 $val)" )
		done
		echo "0 ${words[*]}"
}
```

