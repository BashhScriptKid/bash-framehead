# `colour::wrap`

**Signature:** `colour::wrap(bit, fg_bg, colour, text)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Wrap text in escape codes and return as string (no direct print)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bit` | string | Yes | |
| `fg_bg` | string | Yes | |
| `colour` | string | Yes | |
| `text` | string | Yes | |

## Source

```bash
colour::wrap() {
	local bit="$1" fg_bg="$2" col="$3" text
	if [[ $# -ge 4 ]]; then text="$4"; else text=$(cat); fi
	printf '%s%s%s' "$(colour::esc "$bit" "$fg_bg" "$col")" "$text" "$(colour::reset)"
}
```

