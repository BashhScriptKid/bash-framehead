# `device::random`

**Signature:** `device::random([bytes])`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Read n random bytes from /dev/urandom

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bytes` | string | No | |

## Source

```bash
device::random() {
		local bytes="${1:-16}"
		dd if=/dev/urandom bs=1 count="$bytes" 2>/dev/null | od -An -tx1 | tr -d ' \n'
		echo
}
```

