# `random::native::range`

**Signature:** `random::native::range(min, max)`

**Module:** [`random`](../../random.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Returns a value in [min, max] inclusive

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `min` | string | Yes | |
| `max` | string | Yes | |

## Source

```bash
random::native::range() {
		local min="$1" max="$2"
		echo $(( (RANDOM % (max - min + 1)) + min ))
}
```

