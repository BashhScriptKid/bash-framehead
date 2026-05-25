# `runtime::argv0::set`

**Signature:** `runtime::argv0::set(my-script)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Set $0 to a new value.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `my-script` | string | Yes | |

## Source

```bash
runtime::argv0::set() {
		[[ -n "${1:-}" ]] || { echo "runtime::argv0::set: name required" >&2; return 1; }
		if [[ -z "${BASH_ARGV0+set}" ]]; then
				echo "runtime::argv0::set: requires Bash 5.0+" >&2; return 1
		fi
		BASH_ARGV0="$1"
}
```

