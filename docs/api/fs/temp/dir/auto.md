# `fs::temp::dir::auto`

**Signature:** `fs::temp::dir::auto(arg1)`

**Module:** [`fs`](../../../fs.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Create a temp dir and register cleanup on EXIT

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::temp::dir::auto() {
		local tmp
		tmp=$(fs::temp::dir "$1")
		# shellcheck disable=SC2064
		trap "rm -rf '$tmp'" EXIT
		echo "$tmp"
}
```

