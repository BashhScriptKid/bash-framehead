# `hash::crc32`

CRC32 — delegates to system tools, pure bash fallback is too slow for real use

## Usage

```bash
hash::crc32 string
```

## Source

```bash
hash::crc32() {
    local s="$1"
    if runtime::has_command crc32; then
        printf '%s' "$s" | crc32 /dev/stdin 2>/dev/null
    elif runtime::has_command python3; then
        python3 -c "import binascii,sys; print('%08x' % (binascii.crc32(sys.argv[1].encode()) & 0xffffffff))" "$s"
    elif runtime::has_command cksum; then
        # cksum uses CRC but with a different algorithm — close but not standard CRC32
        printf '%s' "$s" | cksum | awk '{print $1}'
    else
        echo "hash::crc32: requires crc32, python3, or cksum" >&2
        return 1
    fi
}
```

## Module

[`hash`](../hash.md)
