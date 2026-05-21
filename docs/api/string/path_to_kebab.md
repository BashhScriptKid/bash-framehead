# `string::path_to_kebab`

**Signature:** `string::path_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

path/case → kebab-case


## Source

```bash
string::path_to_kebab() {
  local input; _string::read_input input "$@"
  local path="$input"
  path="${path//\\/-}"  # Replace backslashes
  path="${path//\//-}"  # Replace forward slashes
  echo "$path"
}
```

