# `runtime::execignore::add`

**Signature:** `runtime::execignore::add('*.py')`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

PATH CONTROL

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `*.py` | string | Yes | |

## Source

```bash
runtime::execignore::add() {
		local _pat=$1
		[[ -n "$_pat" ]] || {
			echo "runtime::execignore::add: pattern required" >&2
			return 1
		}
		if [[ -z "${EXECIGNORE:-}" ]]; then
				EXECIGNORE="$_pat"
		else
				EXECIGNORE="$EXECIGNORE:$_pat"
		fi
}
```

