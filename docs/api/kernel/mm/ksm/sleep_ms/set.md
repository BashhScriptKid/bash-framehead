# `kernel::mm::ksm::sleep_ms::set`

**Signature:** `kernel::mm::ksm::sleep_ms::set(arg1)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::mm::ksm::sleep_ms::set() {
	runtime::is_root || { echo "kernel::mm::ksm::sleep_ms::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/sleep_millisecs
}
```

