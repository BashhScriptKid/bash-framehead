# `math::factorial`

Factorial (integer)

## Usage

```bash
math::factorial n
```

## Source

```bash
math::factorial() {
    local n="$1" result=1
    (( n < 0 )) && { echo "math::factorial: negative input" >&2; return 1; }
    local i
    for (( i=2; i<=n; i++ )); do result=$(( result * i )); done
    echo "$result"
}
```

## Module

[`math`](../math.md)
