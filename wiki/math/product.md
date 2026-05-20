# `math::product`

Product of a sequence of integers

## Source

```bash
math::product() {
    local result=1
    for n in "$@"; do (( result *= n )); done
    echo "$result"
}
```

## Module

[`math`](../math.md)
