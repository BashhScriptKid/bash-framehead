# `string::uuid`

**Signature:** `string::uuid()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Generate a UUID v4 (random)


## Source

```bash
string::uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  elif [[ -f /proc/sys/kernel/random/uuid ]]; then
    cat /proc/sys/kernel/random/uuid
  else
    # Manual construction from /dev/urandom
    local b
    b=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
    printf '%s-%s-4%s-%s%s-%s\n' \
      "${b:0:8}" "${b:8:4}" "${b:13:3}" \
      "$(((16#${b:16:1} & 3) | 8))${b:17:3}" \
      "${b:20:4}" "${b:24:12}"
  fi
}
```

