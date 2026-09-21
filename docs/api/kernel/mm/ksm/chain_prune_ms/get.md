# `kernel::mm::ksm::chain_prune_ms::get`

**Signature:** `kernel::mm::ksm::chain_prune_ms::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::chain_prune_ms::get() {
	cat /sys/kernel/mm/ksm/stable_node_chains_prune_millisecs 2>/dev/null || echo "unknown"
}
```

