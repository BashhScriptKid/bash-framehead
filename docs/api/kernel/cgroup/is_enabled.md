# `kernel::cgroup::is_enabled`

**Signature:** `kernel::cgroup::is_enabled(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::cgroup::is_enabled() {
	local _feature="$1" _features
	_features=$(cat /sys/kernel/cgroup/features 2>/dev/null) || return 1
	[[ "$_features" == *"$_feature"* ]]
}
```

