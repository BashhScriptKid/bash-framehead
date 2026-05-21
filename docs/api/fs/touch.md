# `fs::touch`

**Signature:** `fs::touch(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Touch a file (create or update timestamp)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::touch() {
    touch "$1"
}
```

