# `timedate::timestamp::to_human`

Convert unix timestamp to human-readable

## Usage

```bash
timedate::timestamp::to_human timestamp [format]
```

## Source

```bash
timedate::timestamp::to_human() {
    local ts="$1" fmt="${2:-%Y-%m-%d %H:%M:%S}"
    _timedate::format "$fmt" "$ts"
}
```

## Module

[`timedate`](../timedate.md)
