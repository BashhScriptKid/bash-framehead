# `math::is_palindrome`

Check if integer is a palindrome

## Source

```bash
math::is_palindrome() {
    local n="${1#-}"
    local rev
    rev=$(math::digit_reverse "$n")
    (( n == rev ))
}
```

## Module

[`math`](../math.md)
