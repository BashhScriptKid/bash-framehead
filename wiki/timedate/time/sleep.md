# `timedate::time::sleep`

Sleep with a progress indicator

## Usage

```bash
timedate::time::sleep seconds [message]
```

## Source

```bash
timedate::time::sleep() {
    local secs="$1" msg="${2:-Waiting}"
    local i
    for (( i=secs; i>0; i-- )); do
        printf '\r%s... %ds ' "$msg" "$i"
        sleep 1
    done
    printf '\r%s... done\n' "$msg"
}
```

## Module

[`timedate`](../timedate.md)
