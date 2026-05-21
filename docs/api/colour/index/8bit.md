# `colour::index::8bit`

**Signature:** `colour::index::8bit(colour_name)`

**Module:** [`colour`](../../colour.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get 8-bit colour index (0-255)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `colour_name` | variable | Yes | |

## Source

```bash
colour::index::8bit() {
    local key="${1,,}"

    # Handle bright prefix
    local is_bright=0
    if [[ "$key" == bright* ]]; then
        is_bright=1
        key="${key#bright}"
        key="${key# }"
    fi

    # Named colours (0-7, or 8-15 if bright)
    local val=-1
    case "$key" in
        black)   val=0 ;;
        red)     val=1 ;;
        green)   val=2 ;;
        yellow)  val=3 ;;
        blue)    val=4 ;;
        magenta) val=5 ;;
        cyan)    val=6 ;;
        white)   val=7 ;;
    esac

    if (( val >= 0 )); then
        (( is_bright )) && val=$(( val + 8 ))
        echo "$val"
        return 0
    fi

    # RGB cube (16-231): rgb0,0,0 to rgb5,5,5 or bare R,G,B
    if [[ "$key" =~ ^(rgb)?([0-5]),([0-5]),([0-5])$ ]]; then
        local r="${BASH_REMATCH[2]}" g="${BASH_REMATCH[3]}" b="${BASH_REMATCH[4]}"
        (( is_bright )) && echo "colour::index::8bit: bright ignored for RGB" >&2
        echo $(( 16 + r * 36 + g * 6 + b ))
        return 0
    fi

    # Greyscale (232-255): grey0-grey23 or gray0-gray23
    if [[ "$key" =~ ^(gr[ae]y)?([0-9]+)$ ]]; then
        local n="${BASH_REMATCH[2]}"
        # Warn on bare numbers — ambiguous intent
        [[ "$key" =~ ^[0-9]+$ ]] && \
            echo "colour::index::8bit: bare number interpreted as greyscale index" >&2
        (( n >= 0 && n <= 23 )) || { echo "colour::index::8bit: greyscale index must be 0-23" >&2; return 1; }
        echo $(( 232 + n ))
        return 0
    fi

    echo "colour::index::8bit: unrecognised colour '${1}'" >&2
    return 1
}
```

