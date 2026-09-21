# `log::debug`

**Signature:** `log::debug([ctx], message)`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- PUBLIC API ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ctx` | string | No | |
| `message` | string | Yes | |

## Example

```bash
Example:
```

## Source

```bash
log::debug() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		_log::emit "$_ctx_name" "DEBUG" $LOG_DEBUG "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}
```

