# `hardware::partition::count`

_No description available._

## Source

```bash
hardware::partition::count() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -no NAME 2>/dev/null | grep -v '^loop' | wc -l | xargs
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c '^\s*[0-9]'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
