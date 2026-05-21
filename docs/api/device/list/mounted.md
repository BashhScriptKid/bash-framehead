# `device::list::mounted`

**Signature:** `device::list::mounted(arg1, arg2, arg3)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

List mounted devices with their mount points

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
device::list::mounted() {
    case "$(runtime::os)" in
    linux|wsl)
        grep '^/dev/' /proc/mounts 2>/dev/null | awk '{print $1, $2}'
        ;;
    darwin)
        mount 2>/dev/null | awk '/^\/dev\// { print $1, $3 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

