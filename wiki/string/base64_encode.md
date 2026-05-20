# `string::base64_encode`

Base64 encode

## Source

```bash
string::base64_encode() {
    case "$(runtime::os)" in
    darwin) echo -n "$1" | base64 ;;
    *)      echo -n "$1" | base64 -w 0 ;;
    esac
}
```

## Module

[`string`](../string.md)
