# `kernel::modules::reload`

**Signature:** `kernel::modules::reload(arg1)`

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
kernel::modules::reload() {
	local _module="$1"
	kernel::modules::unload "$_module"
	sleep 0.5
	kernel::modules::load "$_module"
}
```

