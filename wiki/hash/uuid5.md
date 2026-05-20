# `hash::uuid5`

Generate a hash-based UUID v5 (name-based, SHA1)

## Usage

```bash
hash::uuid5 namespace name
```
Namespace can be a UUID or a well-known string

## Source

```bash
hash::uuid5() {
    if runtime::has_command python3; then
        python3 -c "
import uuid, sys
ns = sys.argv[1]
name = sys.argv[2]
try:
    namespace = uuid.UUID(ns)
except ValueError:
    namespace = uuid.uuid5(uuid.NAMESPACE_DNS, ns)
print(uuid.uuid5(namespace, name))
" "$1" "$2"
    elif runtime::has_command uuidgen; then
        # uuidgen doesn't support v5 on all platforms — fall back to sha1-based manual construction
        local raw
        raw=$(hash::sha1 "${1}:${2}")
        printf '%s-%s-%s-%s-%s\n' \
            "${raw:0:8}" "${raw:8:4}" "5${raw:13:3}" \
            "$(printf '%x' $(( (16#${raw:16:2} & 0x3f) | 0x80 )))${raw:18:2}" \
            "${raw:20:12}"
    else
        echo "hash::uuid5: requires python3 or uuidgen" >&2
        return 1
    fi
}
```

## Module

[`hash`](../hash.md)
