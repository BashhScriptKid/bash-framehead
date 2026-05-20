# `net::dns::txt`

Get TXT records (useful for SPF, DKIM etc.)

## Source

```bash
net::dns::txt() {
    net::dns::records "$1" TXT
}
```

## Module

[`net`](../net.md)
