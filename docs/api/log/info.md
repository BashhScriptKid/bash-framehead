# `log::info`

**Signature:** `log::info([ctx], message)`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log an informational message

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
log::info() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		_log::emit "$_ctx_name" "INFO" $LOG_INFO "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}
```

