# `math::div`

Integer division (truncated toward zero)

## Usage

```bash
math::div dividend divisor
```

## Source

```bash
math::div() {
    echo $(( $1 / $2 ))
}
```

## Module

[`math`](../math.md)
