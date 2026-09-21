# `kernel::mm::hugepages::overcommit::set`

**Signature:** `kernel::mm::hugepages::overcommit::set(arg1)`

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
kernel::mm::hugepages::overcommit::set() {
	runtime::is_root || { echo "kernel::mm::hugepages::overcommit::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/nr_overcommit_hugepages
}
```

