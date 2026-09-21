# `kernel::cgroup::stat`

**Signature:** `kernel::cgroup::stat(arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::cgroup::stat() {
	local _dir="/sys/fs/cgroup"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _descendants _dying
	_descendants=$(cat "$_dir/cgroup.stat" 2>/dev/null | awk '/nr_descendants/{print $2}') || _descendants="?"
	_dying=$(cat "$_dir/cgroup.stat" 2>/dev/null | awk '/nr_dying_descendants/{print $2}') || _dying="?"
	printf 'descendants=%s dying=%s\n' "$_descendants" "$_dying"
}
```

