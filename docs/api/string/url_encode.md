# `string::url_encode`

**Signature:** `string::url_encode(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

URL-encode a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::url_encode() {
    local input; _string::read_input input "$@"
    local s="$input" encoded="" i char hex
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

