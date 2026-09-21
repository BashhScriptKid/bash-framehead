# `kernel::power::suspend_stats`

**Signature:** `kernel::power::suspend_stats()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::power::suspend_stats() {
	local _dir="/sys/power/suspend_stats"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _success _fail _reason
	_success=$(cat "$_dir/success" 2>/dev/null) || _success=0
	_fail=$(cat "$_dir/fail" 2>/dev/null) || _fail=0
	_reason=$(cat "$_dir/last_failed_step" 2>/dev/null) || _reason=""
	printf 'success=%s fail=%s' "$_success" "$_fail"
	[[ -n "$_reason" ]] && printf ' last_failed_step=%s' "$_reason"
	echo
}
```

