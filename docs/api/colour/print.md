# `colour::print`

**Signature:** `colour::print(bit, fg_bg, colour, text)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- HIGHER-LEVEL HELPERS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bit` | string | Yes | |
| `fg_bg` | string | Yes | |
| `colour` | string | Yes | |
| `text` | string | Yes | |

## Source

```bash
colour::print() {
	local bit="$1" fg_bg="$2" col="$3" text
	if [[ $# -ge 4 ]]; then text="$4"; else text=$(cat); fi
	colour::esc "$bit" "$fg_bg" "$col"
	printf '%s' "$text"
	colour::reset
}
```

