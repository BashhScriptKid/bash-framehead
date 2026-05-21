# `string::base64_encode`

**Signature:** `string::base64_encode(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Base64 encode

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::base64_encode() {
    local input; _string::read_input input "$@"
    case "$(runtime::os)" in
    darwin) echo -n "$input" | base64 ;;
    *)      echo -n "$input" | base64 -w 0 ;;
    esac
}
```

