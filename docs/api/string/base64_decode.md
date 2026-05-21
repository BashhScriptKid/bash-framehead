# `string::base64_decode`

**Signature:** `string::base64_decode(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Base64 decode

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::base64_decode() {
    local input; _string::read_input input "$@"
    case "$(runtime::os)" in
    darwin) echo -n "$input" | base64 -D ;;
    *)      echo -n "$input" | base64 --decode ;;
    esac
}
```

