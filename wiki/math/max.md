# `math::max`

Maximum of two values

## Source

```bash
math::max() {
    echo $(( $1 > $2 ? $1 : $2 ))
}
```

## Module

[`math`](../math.md)
