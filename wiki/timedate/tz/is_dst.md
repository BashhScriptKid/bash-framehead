# `timedate::tz::is_dst`

Check if currently in daylight saving time

## Source

```bash
timedate::tz::is_dst() {
    local dst
    dst=$(date +%Z)
    # Most DST zones have a different abbreviation (EDT vs EST, BST vs GMT, etc.)
    # This is a heuristic — not universally reliable
    [[ "$dst" =~ DT$|BST|CEST|IST|NZDT|AEDT|AEST ]]
}
```

## Module

[`timedate`](../timedate.md)
