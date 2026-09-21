# `kernel::power::can_suspend`

**Signature:** `kernel::power::can_suspend()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::can_suspend() {
	local _states
	_states=$(cat /sys/power/state 2>/dev/null) || return 1
	[[ "$_states" == *"mem"* ]]
}
```

