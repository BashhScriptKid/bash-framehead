# `fs::path::absolute`

Get absolute path (resolves . and .. without requiring the path to exist)

## Source

```bash
fs::path::absolute() {
    local p="$1"
    if [[ "$p" != /* ]]; then
        p="$(pwd)/$p"
    fi
    # Resolve . and .. manually
    local -a parts=() result=()
    IFS='/' read -ra parts <<< "$p"
    for part in "${parts[@]}"; do
        case "$part" in
            ""|.) ;;
            ..)   [[ ${#result[@]} -gt 0 ]] && unset 'result[-1]' ;;
            *)    result+=("$part") ;;
        esac
    done
    echo "/${result[*]// //}"
}
```

## Module

[`fs`](../fs.md)
