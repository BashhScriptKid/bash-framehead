# `runtime::coproc::start`

**Signature:** `runtime::coproc::start(<registry>, <name>, <command...>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- COPROC ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<registry>` | string | Yes | |
| `<name>` | string | Yes | |
| `<command...>` | string | — | |

## Source

```bash
runtime::coproc::start() {
		local -n _registry="$1"; shift
		local _name=$1; shift
		if [[ -z "$_name" ]]; then
				echo "runtime::coproc::start: name required" >&2
				return 1
		fi
		if [[ " ${_registry[*]} " == *" $_name "* ]]; then
				echo "runtime::coproc::start: coproc '$_name' already exists" >&2
				return 1
		fi
		coproc "$_name" { "$@" 2>&1; }
		_registry+=("$_name")
}
```

