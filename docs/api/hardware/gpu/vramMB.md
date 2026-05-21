# `hardware::gpu::vramMB`

**Signature:** `hardware::gpu::vramMB()`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
hardware::gpu::vramMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        if runtime::has_command nvidia-smi; then
            nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1
        elif runtime::has_command lspci; then
            lspci -v 2>/dev/null \
                | grep -A12 'VGA' \
                | grep 'prefetchable' \
                | grep -oE '[0-9]+M' | head -1 | tr -d 'M'
        else
            echo "unknown"
        fi
        ;;
    darwin)
        system_profiler SPDisplaysDataType 2>/dev/null \
            | awk '/VRAM/ { gsub(/[^0-9]/,"",$NF); print $NF }' | head -1 \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

