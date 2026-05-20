# `hardware::disk::name`

_No description available._

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

## Module

[`hardware`](../hardware.md)
