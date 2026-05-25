# `runtime::coproc::start`

**Signature:** `runtime::coproc::start(<name>, <command...>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Start a named coprocess. Stores name for tracking.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<command...>` | string | — | |

## Source

```bash
runtime::coproc::start() {
		local name=$1; shift
		if [[ -z "$name" ]]; then
				echo "runtime::coproc::start: name required" >&2
				return 1
		fi
		if [[ " ${_RUNTIME_COPROCS[*]} " == *" $name "* ]]; then
				echo "runtime::coproc::start: coproc '$name' already exists" >&2
				return 1
		fi
		coproc "$name" { "$@" 2>&1; }
		_RUNTIME_COPROCS+=("$name")
}
```

