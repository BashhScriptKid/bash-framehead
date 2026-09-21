# `log::fatal`

**Signature:** `log::fatal([ctx], message, [exit_code])`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log an error and always exit, defaulting to exit code 1

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ctx` | string | No | |
| `message` | string | Yes | |
| `exit_code` | integer | No | |

## Example

```bash
Example:
```

## Source

```bash
log::fatal() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		local msg="$1"
		local exit_code="${2:-1}"
		_log::emit "$_ctx_name" "ERROR" $LOG_ERROR "$msg" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
		exit "$exit_code"
}
```

