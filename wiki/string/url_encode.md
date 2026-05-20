# `string::url_encode`

URL-encode a string

## Source

```bash
string::url_encode() {
    local s="$1" encoded="" i char hex
    for (( i=0; i<${#s}; i++ )); do
        char="${s:$i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-]) encoded+="$char" ;;
            *) printf -v hex '%02X' "'$char"
               encoded+="%$hex" ;;
        esac
    done
    echo "$encoded"
}
```

## Module

[`string`](../string.md)
