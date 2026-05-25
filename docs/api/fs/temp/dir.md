# `fs::temp::dir`

**Signature:** `fs::temp::dir(tmpdir=$(fs::temp::dir, [prefix]))`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Create a temporary directory, print its path

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `tmpdir=$(fs::temp::dir` | string | Yes | |
| `[prefix])` | string | Yes | |

## Source

```bash
fs::temp::dir() {
		local prefix="${1:-fsbshf}"
		mktemp -d "/tmp/${prefix}.XXXXXX"
}
```

