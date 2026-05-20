# `timedate::duration::relative`

Human-readable relative time from a unix timestamp

## Usage

```bash
timedate::duration::relative timestamp
```

**Output:** "3 hours ago", "in 2 days"

## Source

```bash
timedate::duration::relative() {
    local ts="$1"
    local now
    now=$(timedate::timestamp::unix)
    local diff=$(( now - ts ))
    local abs_diff=$(( diff < 0 ? -diff : diff ))
    local future=false
    (( diff < 0 )) && future=true

    local result
    if   (( abs_diff < 60 ));     then result="${abs_diff} second$( (( abs_diff != 1 )) && echo s)"
    elif (( abs_diff < 3600 ));   then
        local m=$(( abs_diff / 60 ))
        result="$m minute$( (( m != 1 )) && echo s)"
    elif (( abs_diff < 86400 ));  then
        local h=$(( abs_diff / 3600 ))
        result="$h hour$( (( h != 1 )) && echo s)"
    elif (( abs_diff < 2592000 )); then
        local d=$(( abs_diff / 86400 ))
        result="$d day$( (( d != 1 )) && echo s)"
    elif (( abs_diff < 31536000 )); then
        local mo=$(( abs_diff / 2592000 ))
        result="$mo month$( (( mo != 1 )) && echo s)"
    else
        local y=$(( abs_diff / 31536000 ))
        result="$y year$( (( y != 1 )) && echo s)"
    fi

    $future && echo "in $result" || echo "$result ago"
}
```

## Module

[`timedate`](../timedate.md)
