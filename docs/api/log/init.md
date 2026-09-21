# `log::init`

**Signature:** `log::init([_ctx])`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- INIT ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `_ctx` | string | No | |

## Source

```bash
log::init() {
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				local -n _lctx="$1"
				_log::ensure_defaults
				[[ -z "${_lctx[fmt]:-}" ]]         && _lctx[fmt]="${_LOG_CONFIG[fmt]}"
				[[ -z "${_lctx[file]:-}" ]]        && _lctx[file]="${_LOG_CONFIG[file]}"
				[[ -z "${_lctx[stdout_mask]:-}" ]] && _lctx[stdout_mask]="${_LOG_CONFIG[stdout_mask]}"
				[[ -z "${_lctx[colour]+x}" ]]      && _lctx[colour]="${_LOG_CONFIG[colour]}"
		else
				_log::ensure_defaults
		fi
}
```

