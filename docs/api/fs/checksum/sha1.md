# `fs::checksum::sha1`

**Signature:** `fs::checksum::sha1(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::checksum::sha1() {
		if runtime::has_command sha1sum; then
				sha1sum "$1" | awk '{print $1}'
		elif runtime::has_command shasum; then
				shasum -a 1 "$1" | awk '{print $1}'
		fi
}
```

