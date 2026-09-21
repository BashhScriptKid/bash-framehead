# `kernel::sysrq::oom_kill`

**Signature:** `kernel::sysrq::oom_kill()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::sysrq::oom_kill() {
	echo f > /proc/sysrq-trigger 2>/dev/null
}
```

