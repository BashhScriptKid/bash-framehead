# `device::list::mounted`

List mounted devices with their mount points

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

## Module

[`device`](../device.md)
