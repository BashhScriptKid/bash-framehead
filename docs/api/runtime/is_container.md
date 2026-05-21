# `runtime::is_container`

**Signature:** `runtime::is_container()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

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

