# `timedate::tz::offset_seconds`

Get UTC offset in seconds

## Source

```bash
timedate::tz::offset_seconds() {
    local offset
    offset=$(date +%z)
    local sign="${offset:0:1}"
    local hours=$(( 10#${offset:1:2} ))
    local mins=$(( 10#${offset:3:2} ))
    local total=$(( hours * 3600 + mins * 60 ))
    [[ "$sign" == "-" ]] && total=$(( -total ))
    echo "$total"
}
```

## Module

[`timedate`](../timedate.md)
