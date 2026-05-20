# `string::base32_encode::pure`

_No description available._

## Source

```bash
string::base32_encode::pure() {
    local _B32="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    local s="$1" out="" i a b c d e

    for (( i=0; i<${#s}; i+=5 )); do
        a=$(printf '%d' "'${s:$i:1}")
        b=$(( i+1 < ${#s} ? $(printf '%d' "'${s:$((i+1)):1}") : 0 ))
        c=$(( i+2 < ${#s} ? $(printf '%d' "'${s:$((i+2)):1}") : 0 ))
        d=$(( i+3 < ${#s} ? $(printf '%d' "'${s:$((i+3)):1}") : 0 ))
        e=$(( i+4 < ${#s} ? $(printf '%d' "'${s:$((i+4)):1}") : 0 ))

        out+="${_B32:$(( (a >> 3) & 31 )):1}"
        out+="${_B32:$(( ((a << 2) | (b >> 6)) & 31 )):1}"
        out+="${_B32:$(( i+1 < ${#s} ? (b >> 1) & 31 : 32 )):1}"
        out+="${_B32:$(( i+1 < ${#s} ? ((b << 4) | (c >> 4)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+2 < ${#s} ? ((c << 1) | (d >> 7)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+3 < ${#s} ? (d >> 2) & 31 : 32 )):1}"
        out+="${_B32:$(( i+3 < ${#s} ? ((d << 3) | (e >> 5)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+4 < ${#s} ? e & 31 : 32 )):1}"
    done

    echo "$out"
}
```

## Module

[`string`](../string.md)
