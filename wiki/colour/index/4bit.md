# `colour::index::4bit`

Get 4-bit ANSI colour code index

## Usage

```bash
colour::index::4bit colour_name [fg|bg]
```

## Returns

ANSI code number (30-37, 40-47, 90-97, 100-107)

## Source

```bash
colour::index::4bit() {
    local key="${1,,}" fg_bg="${2:-fg}"

    # Handle bright prefix — "bright red" or "brightred"
    local is_bright=0
    if [[ "$key" == bright* ]]; then
        is_bright=1
        key="${key#bright}"
        key="${key# }"  # strip optional space
    fi

    local val
    case "$key" in
        black)   val=30 ;;
        red)     val=31 ;;
        green)   val=32 ;;
        yellow)  val=33 ;;
        blue)    val=34 ;;
        magenta) val=35 ;;
        cyan)    val=36 ;;
        white)   val=37 ;;
        *)       return 1 ;;
    esac

    (( is_bright )) && val=$(( val + 60 ))
    [[ "$fg_bg" == "bg" ]] && val=$(( val + 10 ))

    echo "$val"
}
```

## Module

[`colour`](../colour.md)
