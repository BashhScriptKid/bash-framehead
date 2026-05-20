# `string::base64_encode::pure`

_No description available._

## Source

```bash
string::base64_encode::pure() {
    local s="$1" out="" i a b c
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    for (( i=0; i<${#s}; i+=3 )); do
        a=$(printf '%d' "'${s:$i:1}")
        b=$(( i+1 < ${#s} ? $(printf '%d' "'${s:$((i+1)):1}") : 0 ))
        c=$(( i+2 < ${#s} ? $(printf '%d' "'${s:$((i+2)):1}") : 0 ))

        out+="${_B64:$(( (a >> 2) & 63 )):1}"
        out+="${_B64:$(( ((a << 4) | (b >> 4)) & 63 )):1}"
        out+="${_B64:$(( i+1 < ${#s} ? ((b << 2) | (c >> 6)) & 63 : 64 )):1}"
        out+="${_B64:$(( i+2 < ${#s} ? c & 63 : 64 )):1}"
    done

    echo "$out"
}
```

## Module

[`string`](../string.md)
