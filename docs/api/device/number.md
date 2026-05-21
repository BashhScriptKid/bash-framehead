# `device::number`

**Signature:** `device::number(arg1, arg2)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns the major:minor device number

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::number() {
    local dev="$1"
    if runtime::has_command stat; then
        case "$(runtime::os)" in
        linux|wsl|cygwin|mingw)
            stat -c '%t:%T' "$dev" 2>/dev/null | \
                awk -F: '{ printf "%d:%d\n", strtonum("0x"$1), strtonum("0x"$2) }'
            ;;
        darwin)
            stat -f '%Hr:%Lr' "$dev" 2>/dev/null
            ;;
        *)
            echo "unknown"
            ;;
        esac
    else
        echo "unknown"
    fi
}
```

