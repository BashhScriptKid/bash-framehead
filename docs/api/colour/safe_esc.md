# `colour::safe_esc`

**Signature:** `colour::safe_esc(bit, fg_bg, colour)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Gracefully degrade — return escape code only if terminal supports the depth

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bit` | string | Yes | |
| `fg_bg` | string | Yes | |
| `colour` | string | Yes | |

## Source

```bash
colour::safe_esc() {
		local bit="$1"
		case "$bit" in
		4)  colour::supports     || return 0 ;;
		8)  colour::supports_256 || return 0 ;;
		24) colour::supports_truecolor || return 0 ;;
		esac
		colour::esc "$@"
}
```

