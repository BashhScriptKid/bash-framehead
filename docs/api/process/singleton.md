# `process::singleton`

**Signature:** `process::singleton(lockname, command, [args...])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Run command only if not already running (singleton)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `lockname` | string | Yes | |
| `command` | command | Yes | |
| `args...` | string | No | |

## Source

```bash
process::singleton() {
		local name="$1"; shift
		if process::lock::acquire "$name"; then
				"$@"
		else
				echo "process::singleton: '$name' is already running" >&2
				return 1
		fi
}
```

