# `runtime::is_minimum_bash`

Default to 3, assuming that's what's at least needed for this framework (not final)

## Source

```bash
runtime::is_minimum_bash() {
  ((BASH_VERSINFO[0] >= ${1:-3}))
}
```

## Module

[`runtime`](../runtime.md)
