# `kernel::ftrace::dump_on_oops::get`

**Signature:** `kernel::ftrace::dump_on_oops::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::ftrace::dump_on_oops::get() {
	cat /proc/sys/kernel/ftrace_dump_on_oops 2>/dev/null || echo "unknown"
}
```

