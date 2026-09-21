# `kernel::modules::info`

**Signature:** `kernel::modules::info(arg1, arg2)`

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
kernel::modules::info() {
	local _module="$1"
	runtime::has_command modinfo || { echo "unknown"; return 1; }
	modinfo "$_module" 2>/dev/null | awk -F':\s*' '/^(filename|description|author|license|depends|vermagic):/{printf "%s=%s\n", $1, $2}'
}
```

