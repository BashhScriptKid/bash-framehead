# `hardware::disk::count::virtual`

**Signature:** `hardware::disk::count::virtual()`

**Module:** [`hardware`](../../../hardware.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
hardware::disk::count::virtual() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME,TYPE 2>/dev/null | grep -c 'loop\|ram'
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c 'virtual'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

