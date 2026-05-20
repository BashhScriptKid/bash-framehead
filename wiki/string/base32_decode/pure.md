# `string::base32_decode::pure`

_No description available._

## Source

```bash
string::base32_decode::pure() {
    local _B32="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    local s="${1//=}" out="" i
    local -i a b c d e f g h

    # uppercase input since base32 alphabet is uppercase only
    s="${s^^}"

    for (( i=0; i<${#s}; i+=8 )); do
        a="${_B32%${s:$i:1}*}"         ; a="${#a}"
        b="${_B32%${s:$((i+1)):1}*}"   ; b="${#b}"
        c="${_B32%${s:$((i+2)):1}*}"   ; c="${#c}"
        d="${_B32%${s:$((i+3)):1}*}"   ; d="${#d}"
        e="${_B32%${s:$((i+4)):1}*}"   ; e="${#e}"
        f="${_B32%${s:$((i+5)):1}*}"   ; f="${#f}"
        g="${_B32%${s:$((i+6)):1}*}"   ; g="${#g}"
        h="${_B32%${s:$((i+7)):1}*}"   ; h="${#h}"

        printf "\\$(printf '%03o' $(( (a << 3) | (b >> 2) )))"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $(( ((b & 3) << 6) | (c << 1) | (d >> 4) )))"
        (( i+4 < ${#s} )) && printf "\\$(printf '%03o' $(( ((d & 15) << 4) | (e >> 1) )))"
        (( i+5 < ${#s} )) && printf "\\$(printf '%03o' $(( ((e & 1) << 7) | (f << 2) | (g >> 3) )))"
        (( i+7 < ${#s} )) && printf "\\$(printf '%03o' $(( ((g & 7) << 5) | h )))"
    done
    echo
}
```

## Module

[`string`](../string.md)
