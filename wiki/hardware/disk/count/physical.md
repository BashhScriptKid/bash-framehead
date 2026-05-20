# `hardware::disk::count::physical`

_No description available._

## Source

```bash
hardware::disk::count::physical() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME,TYPE 2>/dev/null | awk '/disk/ && !/loop/' | wc -l | xargs
        ;;
    darwin)
        diskutil list physical 2>/dev/null | grep -c '^/dev/disk'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
