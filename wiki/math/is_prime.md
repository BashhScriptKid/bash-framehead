# `math::is_prime`

Check if integer is prime

## Source

```bash
math::is_prime() {
    local n="$1"
    (( n < 2 )) && return 1
    (( n == 2 )) && return 0
    (( n % 2 == 0 )) && return 1
    local i=3
    while (( i * i <= n )); do
        (( n % i == 0 )) && return 1
        (( i += 2 ))
    done
    return 0
}
```

## Module

[`math`](../math.md)
