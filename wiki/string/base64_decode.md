# `string::base64_decode`

Base64 decode

## Source

```bash
string::base64_decode() {
    case "$(runtime::os)" in
    darwin) echo -n "$1" | base64 -D ;;
    *)      echo -n "$1" | base64 --decode ;;
    esac
}
```

## Module

[`string`](../string.md)
