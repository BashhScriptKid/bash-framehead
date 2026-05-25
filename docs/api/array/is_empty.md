# `array::is_empty`

**Signature:** `array::is_empty($@)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if array is empty

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `$@` | string | Yes | |

## Source

```bash
array::is_empty() {
		[[ "$#" -eq 0 ]]
}
```

