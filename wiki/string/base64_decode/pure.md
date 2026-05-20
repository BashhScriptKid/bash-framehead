# `string::base64_decode::pure`

_No description available._

## Source

```bash
string::base64_decode::pure() {
    local s="$1" out="" i
    local -i a b c d byte1 byte2 byte3
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    # strip padding
    s="${s//=}"

    for (( i=0; i<${#s}; i+=4 )); do
        a="${_B64%${s:$i:1}*}"     ; a="${#a}"
        b="${_B64%${s:$((i+1)):1}*}"; b="${#b}"
        c="${_B64%${s:$((i+2)):1}*}"; c="${#c}"
        d="${_B64%${s:$((i+3)):1}*}"; d="${#d}"

        byte1=$(( (a << 2) | (b >> 4) ))
        byte2=$(( ((b & 15) << 4) | (c >> 2) ))
        byte3=$(( ((c & 3) << 6) | d ))

        printf "\\$(printf '%03o' $byte1)"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $byte2)"
        (( i+3 < ${#s}  )) && printf "\\$(printf '%03o' $byte3)"
    done
    echo
}
```

## Module

[`string`](../string.md)
