# `fs::path::basename`

**Signature:** `fs::path::basename()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get filename from path (like basename)


## Source

```bash
fs::path::basename() {
		echo "${1##*/}"
}
```

