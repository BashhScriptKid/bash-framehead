# `random::xorshift64`

**Signature:** `random::xorshift64(state)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

XORSHIFT64

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `state` | string | Yes | |

## Source

```bash
random::xorshift64() {
		local x="$1"
		x=$(( x ^ (x << 13) ))
		x=$(( x ^ (x >> 7)  ))
		x=$(( x ^ (x << 17) ))
		echo "$x"
}
```

