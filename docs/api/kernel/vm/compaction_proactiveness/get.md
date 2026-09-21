# `kernel::vm::compaction_proactiveness::get`

**Signature:** `kernel::vm::compaction_proactiveness::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::compaction_proactiveness::get() {
	cat /proc/sys/vm/compaction_proactiveness 2>/dev/null || echo "unknown"
}
```

