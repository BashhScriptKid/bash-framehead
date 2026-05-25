# `terminal::read_key::decode`

**Signature:** `terminal::read_key::decode([varname], [timeout])`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Read a keypress including multi-byte escape sequences.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | No | |
| `timeout` | string | No | |

## Source

```bash
terminal::read_key::decode() {
		local _var="${1:-_TERMINAL_KEY}" _timeout="${2:-}"
		local _key _seq _rest

		IFS= read -r -s -n1 _key
		[[ -z $_key ]] && { printf -v "$_var" ''; return 0; }

		# Named single-byte keys
		case "$_key" in
				$'\n') printf -v "$_var" 'ENTER';   return 0;;
				$'\t') printf -v "$_var" 'TAB';     return 0;;
				$'\x7f'|$'\x08') printf -v "$_var" 'BACKSPACE'; return 0;;
				$'\x1b') ;; # ESC — check for sequence
				*) printf -v "$_var" '%s' "$_key"; return 0;;
		esac

		# ESC received — peek at next byte with a short timeout
		local _timeout_val="${_timeout:-0.01}"
		IFS= read -r -s -n1 -t "$_timeout_val" _seq || { printf -v "$_var" 'ESC'; return 0; }

		case "$_seq" in
				'[') # CSI sequence
						_rest=''
						# Read CSI parameter bytes (digits, semicolons) until terminal byte
						local _byte
						while IFS= read -r -s -n1 -t "$_timeout_val" _byte; do
								case "$_byte" in
										[0-9]|\;) _rest+="$_byte";;
										*) _seq+="$_rest$_byte"; break;;
								esac
						done
						# _seq now holds the full CSI suffix, e.g. "A", "5~", "1;2A"
						case "${_seq#[}" in
								A) printf -v "$_var" 'UP';;
								B) printf -v "$_var" 'DOWN';;
								C) printf -v "$_var" 'RIGHT';;
								D) printf -v "$_var" 'LEFT';;
								H) printf -v "$_var" 'HOME';;
								F) printf -v "$_var" 'END';;
								2~) printf -v "$_var" 'INSERT';;
								3~) printf -v "$_var" 'DELETE';;
								5~) printf -v "$_var" 'PAGEUP';;
								6~) printf -v "$_var" 'PAGEDOWN';;
								11~|15~) printf -v "$_var" 'F5';;
								12~|17~) printf -v "$_var" 'F6';;
								13~|18~) printf -v "$_var" 'F7';;
								14~|19~) printf -v "$_var" 'F8';;
								20~) printf -v "$_var" 'F9';;
								21~) printf -v "$_var" 'F10';;
								23~) printf -v "$_var" 'F11';;
								24~) printf -v "$_var" 'F12';;
								*) printf -v "$_var" '%s' "ESC[${_seq#[}";;
						esac
						;;
				'O') # SS3 sequence (xterm function keys, alternate home/end)
						IFS= read -r -s -n1 -t "$_t" _rest || { printf -v "$_var" 'ESC'; return 0; }
						case "$_rest" in
								P) printf -v "$_var" 'F1';;
								Q) printf -v "$_var" 'F2';;
								R) printf -v "$_var" 'F3';;
								S) printf -v "$_var" 'F4';;
								H) printf -v "$_var" 'HOME';;
								F) printf -v "$_var" 'END';;
								*) printf -v "$_var" '%s' "ESC-O-$_rest";;
						esac
						;;
				*) # Unknown escape — return ESC + the following byte(s)
						printf -v "$_var" '%s' "ESC-$_seq"
						;;
		esac
		return 0
}
```

