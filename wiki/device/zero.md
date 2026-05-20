# `device::zero`

Write n bytes of zeros to a device or file (wraps /dev/zero)

## Usage

```bash
device::zero target [bytes]
```

**WARNING:** Destructive — use with care

## Source

```bash
device::zero() {
    local target="$1" bytes="${2:-16}"
    if [[ -n "$bytes" ]]; then
        dd if=/dev/zero of="$target" bs=1 count="$bytes" 2>/dev/null
    else
        dd if=/dev/zero of="$target" 2>/dev/null
    fi
}
```

## Module

[`device`](../device.md)
