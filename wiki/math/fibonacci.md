# `math::fibonacci`

Fibonacci (nth term, 0-indexed)

## Usage

```bash
math::fibonacci n
```

## Source

```bash
math::fibonacci() {
    local n="$1" a=0 b=1 i
    (( n == 0 )) && echo 0 && return
    for (( i=1; i<n; i++ )); do
        local t=$(( a + b ))
        a=$b
        b=$t
    done
    echo "$b"
}
```

## Module

[`math`](../math.md)
