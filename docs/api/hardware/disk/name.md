# `hardware::disk::name`

**Signature:** `hardware::disk::name(arg2)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
hardware::disk::name() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno MODEL 2>/dev/null | grep -v '^$' | head -1 | xargs
        ;;
    darwin)
        diskutil info disk0 2>/dev/null \
            | awk -F': +' '/Device \/ Media Name/ { print $2 }' | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

