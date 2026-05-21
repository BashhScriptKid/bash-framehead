# `net::fetch::retry`

**Signature:** `net::fetch::retry(url, [output], [retries], [delay])`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Fetch with retry on failure

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | string | Yes | |
| `output` | string | No | |
| `retries` | string | No | |
| `delay` | string | No | |

## Source

```bash
net::fetch::retry() {
    local url="$1" out="${2:--}" retries="${3:-3}" delay="${4:-2}"
    local attempt=0
    while (( attempt < retries )); do
        net::fetch "$url" "$out" && return 0
        (( attempt++ ))
        echo "net::fetch::retry: attempt $attempt failed, retrying in ${delay}s..." >&2
        sleep "$delay"
    done
    echo "net::fetch::retry: all $retries attempts failed" >&2
    return 1
}
```

