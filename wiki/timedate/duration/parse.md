# `timedate::duration::parse`

Parse a duration string into seconds

## Usage

```bash
timedate::duration::parse "1d 2h 3m 4s"
```

## Source

```bash
timedate::duration::parse() {
    local input="$1" total=0
    local -a tokens=($input)
    for token in "${tokens[@]}"; do
        local val unit
        val="${token%[dhms]*}"
        unit="${token##*[0-9]}"
        case "$unit" in
        d) (( total += val * 86400 )) ;;
        h) (( total += val * 3600  )) ;;
        m) (( total += val * 60    )) ;;
        s) (( total += val         )) ;;
        esac
    done
    echo "$total"
}
```

## Module

[`timedate`](../timedate.md)
