# `kernel::power::can_hibernate`

**Signature:** `kernel::power::can_hibernate()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::can_hibernate() {
	local _states
	_states=$(cat /sys/power/state 2>/dev/null) || return 1
	[[ "$_states" == *"disk"* ]]
}
```

