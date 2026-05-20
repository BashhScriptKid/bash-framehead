# `fs::is_empty`

_No description available._

## Source

```bash
fs::is_empty()      { [[ -f "$1" && ! -s "$1" ]] || [[ -d "$1" && -z "$(ls -A "$1" 2>/dev/null)" ]]; }
```

## Module

[`fs`](../fs.md)
