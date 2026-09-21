# `string::expand_prompt`

**Signature:** `string::expand_prompt(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Expand prompt sequences: \u → user, \h → host, \w → cwd (like PS1).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::expand_prompt() {
	(( _RUNTIME_FEATURES & 1 )) || {
		echo "string::expand_prompt: requires Bash 4.4+ (\${var@P})" >&2
		return 1
	}
	local input; _string::read_input input "$@"
	printf '%s\n' "${input@P}"
}
```

