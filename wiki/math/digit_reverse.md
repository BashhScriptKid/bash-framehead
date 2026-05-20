# `math::digit_reverse`

Reverse digits of an integer

## Source

```bash
math::digit_reverse() {
    local n="${1#-}" sign="" result=0
    [[ "$1" == -* ]] && sign="-"
    while (( n > 0 )); do
        result=$(( result * 10 + n % 10 ))
        (( n /= 10 ))
    done
    echo "${sign}${result}"
}
```

## Module

[`math`](../math.md)
