# `device::zero`

**Signature:** `device::zero(target, [bytes])`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- SPECIAL DEVICES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `target` | path | Yes | |
| `bytes` | string | No | |

## Source

```bash
device::zero() {
		local target="$1" bytes="${2:-16}"
		if [[ -n "$bytes" ]]; then
				dd if=/dev/zero of="$target" bs=1 count="$bytes" 2>/dev/null
		else
				dd if=/dev/zero of="$target" 2>/dev/null
		fi
}
```

