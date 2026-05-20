# `random::middle_square`


## Usage

```bash
random::middle_square seed
```

## Returns

next value (4-digit middle square extract)

**WARNING:** Degenerates to 0 for many seeds. Short cycles are common.

## Source

```bash
random::middle_square() {
    local x="$1"
    local squared=$(( x * x ))
    echo $(( (squared / 100) % 10000 ))
}
```

## Module

[`random`](../random.md)
