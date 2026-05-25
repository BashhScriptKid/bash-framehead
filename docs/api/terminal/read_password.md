# `terminal::read_password`

**Signature:** `terminal::read_password(varname, [prompt])`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Read a password (no echo)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |
| `prompt` | string | No | |

## Source

```bash
terminal::read_password() {
		local _var="$1" _prompt="${2:-Password: }"
		local _pass
		printf '%s' "$_prompt"
		terminal::echo::off
		IFS= read -r _pass
		terminal::echo::on
		printf '\n'
		printf -v "$_var" '%s' "$_pass"
}
```

