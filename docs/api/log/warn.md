# `log::warn`

**Signature:** `log::warn([ctx], message)`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log a warning message

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
log::warn() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		_log::emit "$_ctx_name" "WARN" $LOG_WARN "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}
```

