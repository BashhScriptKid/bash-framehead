# `device::is_virtual`

Check if device is a virtual/pseudo device

## Source

```bash
device::is_virtual() {
    case "$1" in
        /dev/null | /dev/zero | /dev/full | /dev/random | \
        /dev/urandom | /dev/stdin | /dev/stdout | /dev/stderr | \
        /dev/fd/* | /dev/ptmx | /dev/tty*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}
```

## Module

[`device`](../device.md)
