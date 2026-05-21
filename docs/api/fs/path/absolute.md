# `fs::path::absolute`

**Signature:** `fs::path::absolute(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get absolute path (resolves . and .. without requiring the path to exist)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

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

