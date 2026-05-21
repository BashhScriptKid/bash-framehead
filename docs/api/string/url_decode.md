# `string::url_decode`

**Signature:** `string::url_decode()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
string::url_decode() {
    local input; _string::read_input input "$@"
    local s="${input//+/ }"  # replace + with space first
    printf '%b\n' "${s//%/\\x}"
}
```

