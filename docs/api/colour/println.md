# `colour::println`

**Signature:** `colour::println()`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Print text in colour followed by newline


## Source

```bash
colour::println() {
  colour::print "$@"
  printf '\n'
}
```

