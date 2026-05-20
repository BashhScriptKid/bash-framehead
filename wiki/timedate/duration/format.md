# `timedate::duration::format`

Format seconds into human-readable duration

## Usage

```bash
timedate::duration::format seconds
```

**Output:** 1d 2h 3m 4s

## Source

```bash
timedate::duration::format() {
    local total="$1"
    local neg=""
    (( total < 0 )) && neg="-" && total=$(( -total ))

    local days=$(( total / 86400 ))
    local hours=$(( (total % 86400) / 3600 ))
    local mins=$(( (total % 3600) / 60 ))
    local secs=$(( total % 60 ))

    local result=""
    (( days  > 0 )) && result+="${days}d "
    (( hours > 0 )) && result+="${hours}h "
    (( mins  > 0 )) && result+="${mins}m "
    (( secs  > 0 || total == 0 )) && result+="${secs}s"

    echo "${neg}${result% }"
}
```

## Module

[`timedate`](../timedate.md)
