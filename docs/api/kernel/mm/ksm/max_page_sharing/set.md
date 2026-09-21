# `kernel::mm::ksm::max_page_sharing::set`

**Signature:** `kernel::mm::ksm::max_page_sharing::set(arg1)`

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
kernel::mm::ksm::max_page_sharing::set() {
	runtime::is_root || { echo "kernel::mm::ksm::max_page_sharing::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/max_page_sharing
}
```

