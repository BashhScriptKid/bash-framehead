# `kernel::vm::compaction_proactiveness::set`

**Signature:** `kernel::vm::compaction_proactiveness::set(arg1)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::vm::compaction_proactiveness::set() {
	runtime::is_root || { echo "kernel::vm::compaction_proactiveness::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/compaction_proactiveness
}
```

