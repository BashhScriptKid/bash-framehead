# `kernel::mm::ksm::merge_across_nodes::get`

**Signature:** `kernel::mm::ksm::merge_across_nodes::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::merge_across_nodes::get() {
	cat /sys/kernel/mm/ksm/merge_across_nodes 2>/dev/null || echo "unknown"
}
```

