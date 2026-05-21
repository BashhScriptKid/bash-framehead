# `device::list::block`

**Signature:** `device::list::block(arg1)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

List all block devices

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::list::block() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | sed 's/^/\/dev\//' | grep -v loop
        ;;
    darwin)
        diskutil list 2>/dev/null | awk '/^\/dev\// { print $1 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

