# `random::xorshift64`


## Usage

```bash
random::xorshift64 state
```

## Returns

next state (also the output value)

## Source

```bash
random::xorshift64() {
    local x="$1"
    x=$(( x ^ (x << 13) ))
    x=$(( x ^ (x >> 7)  ))
    x=$(( x ^ (x << 17) ))
    echo "$x"
}
```

## Module

[`random`](../random.md)
