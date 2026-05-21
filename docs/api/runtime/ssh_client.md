# `runtime::ssh_client`

**Signature:** `runtime::ssh_client()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::ssh_client() {
  echo "${SSH_CLIENT%% *}"  # First part is client IP
}
```

