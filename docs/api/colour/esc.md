# `colour::esc`

**Signature:** `colour::esc(bit, fg_bg, colour, [colour...])`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- ESCAPE CODE GENERATION ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bit` | string | Yes | |
| `fg_bg` | string | Yes | |
| `colour` | string | Yes | |
| `colour...` | string | No | |

## Source

```bash
colour::esc() {
		local bit="${1:-}" fg_bg="${2:-fg}"; shift 2
		[[ -n "$bit" ]] || return 1

		case "$bit" in
		4)
				local index
				index=$(colour::index::4bit "$*" "$fg_bg") || return 1
				printf '\033[%sm' "$index"
				;;
		8)
				local index
				index=$(colour::index::8bit "$*") || return 1
				if [[ "$fg_bg" == "bg" ]]; then
						printf '\033[48;5;%sm' "$index"
				else
						printf '\033[38;5;%sm' "$index"
				fi
				;;
		24)
				local r g b
				if [[ "$1" =~ ^(rgb)?([0-9]+),([0-9]+),([0-9]+)$ ]]; then
						r="${BASH_REMATCH[2]}"
						g="${BASH_REMATCH[3]}"
						b="${BASH_REMATCH[4]}"
				else
						echo "colour::esc: 24-bit expects R,G,B format" >&2
						return 1
				fi
				# Clamp to 0-255
				(( r = r > 255 ? 255 : r ))
				(( g = g > 255 ? 255 : g ))
				(( b = b > 255 ? 255 : b ))
				if [[ "$fg_bg" == "bg" ]]; then
						printf '\033[48;2;%s;%s;%sm' "$r" "$g" "$b"
				else
						printf '\033[38;2;%s;%s;%sm' "$r" "$g" "$b"
				fi
				;;
		*)
				echo "colour::esc: bit depth must be 4, 8, or 24" >&2
				return 1
				;;
		esac
}
```

