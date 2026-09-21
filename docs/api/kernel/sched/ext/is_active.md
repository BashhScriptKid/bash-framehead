# `kernel::sched::ext::is_active`

**Signature:** `kernel::sched::ext::is_active()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::sched::ext::is_active() {
	local _state
	_state=$(cat /sys/kernel/sched_ext/state 2>/dev/null) || return 1
	[[ "$_state" != "disabled" ]]
}
```

