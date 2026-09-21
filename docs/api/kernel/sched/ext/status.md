# `kernel::sched::ext::status`

**Signature:** `kernel::sched::ext::status()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- SCHEDULER ---


## Source

```bash
kernel::sched::ext::status() {
	local _state _seq _rejected
	_state=$(cat /sys/kernel/sched_ext/state 2>/dev/null) || { echo "unknown"; return 1; }
	_seq=$(cat /sys/kernel/sched_ext/enable_seq 2>/dev/null) || _seq="?"
	_rejected=$(cat /sys/kernel/sched_ext/nr_rejected 2>/dev/null) || _rejected="?"
	printf 'state=%s seq=%s rejected=%s\n' "$_state" "$_seq" "$_rejected"
}
```

