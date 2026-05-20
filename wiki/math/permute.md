# `math::permute`

Number of permutations P(n, k)

## Usage

```bash
math::permute n k
```

## Source

```bash
math::permute() {
    local n="$1" k="$2" result=1 i
    for (( i=0; i<k; i++ )); do
        result=$(( result * (n - i) ))
    done
    echo "$result"
}
```

## Module

[`math`](../math.md)
