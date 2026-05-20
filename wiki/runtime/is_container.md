# `runtime::is_container`

_No description available._

## Source

```bash
runtime::is_container() {
  [[ -f /.dockerenv ]] ||
  [[ -f /run/.containerenv ]] ||
  grep -q "docker\|lxc\|kubepods" /proc/1/cgroup 2>/dev/null ||
  [[ -n "$CONTAINER" ]] ||
  [[ -n "$KUBERNETES_SERVICE_HOST" ]]
}
```

## Module

[`runtime`](../runtime.md)
