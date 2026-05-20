# `device::random`

Read n random bytes from /dev/urandom

## Usage

```bash
device::random [bytes]
```

## Source

```bash
device::random() {
    local bytes="${1:-16}"
    dd if=/dev/urandom bs=1 count="$bytes" 2>/dev/null | od -An -tx1 | tr -d ' \n'
    echo
}
```

## Module

[`device`](../device.md)
