# `math::digit_count`

Count number of digits

## Source

```bash
math::digit_count() {
    local n="${1#-}"
    (( n == 0 )) && echo 1 && return
    local count=0
    while (( n > 0 )); do
        (( count++ ))
        (( n /= 10 ))
    done
    echo "$count"
}
```

## Module

[`math`](../math.md)
