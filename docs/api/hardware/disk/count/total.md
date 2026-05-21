# `hardware::disk::count::total`

**Signature:** `hardware::disk::count::total()`

**Module:** [`hardware`](../../../hardware.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
hardware::disk::count::total() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | grep -v '^loop' | wc -l | xargs
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c '^/dev/disk'
        ;;
    *)
        hardware::disk::devices | wc -w | xargs
        ;;
    esac
}
```

