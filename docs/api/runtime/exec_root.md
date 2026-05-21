# `runtime::exec_root`

**Signature:** `runtime::exec_root()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::exec_root() {
  # Already root, nothing to do
  if runtime::is_root; then
    return 0
  fi

  if runtime::has_command sudo; then
    # In a non-terminal context, check if sudo can run without a password prompt
    # -n flag makes sudo fail immediately instead of hanging if password is needed
    if ! runtime::is_terminal && ! sudo -n true 2>/dev/null; then
      echo "runtime::request_root: sudo requires a password but no terminal is available, will attempt alternatives." >&2
      # Fall through to other methods
    else
      sudo "$@"
      return $?
    fi
  fi

  if runtime::has_command pkexec && runtime::is_desktop; then
    pkexec "$@"
  elif runtime::has_command doas; then
    doas "$@"
  elif runtime::has_command su; then
    # su -c takes a single string, fragile with spaces in arguments
    su -c "exec $(printf '%q ' "$@")" root
  else
    echo "runtime::request_root: no privilege escalation method found" >&2
    return 1
  fi
}
```

