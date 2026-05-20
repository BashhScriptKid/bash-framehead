# `timedate::date::format`

Current date in a custom format

## Usage

```bash
timedate::date::format [format] [timestamp]
```

## Source

```bash
timedate::date::format() {
    local fmt="${1:-%Y-%m-%d}" ts="${2:-}"
    _timedate::format "$fmt" "$ts"
}
```

## Module

[`timedate`](../timedate.md)
