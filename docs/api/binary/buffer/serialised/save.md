# `binary::buffer::serialised::save`

**Signature:** `binary::buffer::serialised::save(<name>, <filepath>)`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- SERIALISATION ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<filepath>` | string | Yes | |

## Source

```bash
binary::buffer::serialised::save() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local file=$2
	if (( ${#_bbuf_ref[@]} > 0 )); then
		_binary::_emit_raw _bbuf_ref > "$file"
	fi
}
```

