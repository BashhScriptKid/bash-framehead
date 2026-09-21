# `kernel::modules::depends`

**Signature:** `kernel::modules::depends(arg1, arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
kernel::modules::depends() {
	local _module="$1"
	runtime::has_command modinfo || { echo ""; return 1; }
	modinfo "$_module" 2>/dev/null | awk -F':\s*' '/^depends:/{print $2}' | tr ',' '\n' | grep -v '^$'
}
```

