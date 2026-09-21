# `binary::buffer::serialised::load`

**Signature:** `binary::buffer::serialised::load(<name>, <filepath>)`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Load raw bytes from a file into the buffer (replaces contents).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<filepath>` | string | Yes | |

## Source

```bash
binary::buffer::serialised::load() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local file=$2
	_bbuf_ref=()
	if [[ -f "$file" && -r "$file" ]]; then
		local byte_data; byte_data=$(LC_ALL=C od -An -tu1 -v "$file")
		read -r -a _bbuf_ref <<< "$byte_data"
	fi
}
```

