# `timedate::time::sleep`

**Signature:** `timedate::time::sleep(seconds, [message])`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Sleep with a progress indicator

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seconds` | string | Yes | |
| `message` | string | No | |

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

