# `fs::size::human`

**Signature:** `fs::size::human(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Human-readable file size

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::size::human() {
    local size
    size=$(fs::size "$1")
    if runtime::has_command numfmt; then
        numfmt --to=iec-i --suffix=B "$size"
    else
        awk -v s="$size" 'BEGIN {
            split("B KiB MiB GiB TiB", u)
            i=1; while(s>=1024 && i<5){s/=1024; i++}
            printf "%.1f%s\n", s, u[i]
        }'
    fi
}
```

