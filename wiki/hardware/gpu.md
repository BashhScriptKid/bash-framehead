# `hardware::gpu`

_No description available._

## Source

```bash
hardware::gpu() {
    case "$(runtime::os)" in
        linux|wsl|cygwin|mingw)
            if runtime::has_command nvidia-smi; then
                nvidia-smi -q 2>/dev/null | awk -F': ' '/Product Name/ { print $2; exit }' | xargs
            elif runtime::has_command lspci; then
                lspci -mm 2>/dev/null | awk -F'"' \
                    '/VGA|3D|Display/ { print $6 }' | head -1 | xargs
            elif runtime::has_command glxinfo; then
                glxinfo 2>/dev/null | awk -F': ' \
                    '/OpenGL renderer string/ { print $2 }' | head -1 | xargs
            else
                echo "unknown"
            fi
            ;;
    darwin)
        system_profiler SPDisplaysDataType 2>/dev/null \
            | awk -F': ' '/Chipset Model/ { printf $2", " }' \
            | sed 's/, $//' | xargs
        ;;
    freebsd|dragonfly)
        pciconf -lv 2>/dev/null \
            | grep -A4 'VGA' \
            | awk -F'=' '/device/ { gsub(/"/, "", $2); print $2 }' \
            | head -1 | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
