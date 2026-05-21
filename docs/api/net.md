# `net`

38 functions. [Guide](../guide/index.md) — [Dictionary](index.md)

| Function | Signature | Description |
|----------|-----------|-------------|
| [`net::can_reach`](net/can_reach.md) | `net::can_reach(host, [timeout_seconds])` |  |
| [`net::dns::mx`](net/dns/mx.md) | `net::dns::mx(arg1)` |  |
| [`net::dns::ns`](net/dns/ns.md) | `net::dns::ns(arg1)` |  |
| [`net::dns::propagation`](net/dns/propagation.md) | `net::dns::propagation(hostname)` |  |
| [`net::dns::records`](net/dns/records.md) | `net::dns::records(hostname, [type])` |  |
| [`net::dns::txt`](net/dns/txt.md) | `net::dns::txt(arg1)` |  |
| [`net::fetch`](net/fetch.md) | `net::fetch(url, [output_file])` |  |
| [`net::fetch::progress`](net/fetch/progress.md) | `net::fetch::progress(arg1)` |  |
| [`net::fetch::retry`](net/fetch/retry.md) | `net::fetch::retry(url, [output], [retries], [delay])` |  |
| [`net::gateway`](net/gateway.md) | `net::gateway(arg2, arg3)` |  |
| [`net::hostname::fqdn`](net/hostname/fqdn.md) | `net::hostname::fqdn()` |  |
| [`net::hostname`](net/hostname.md) | `net::hostname()` |  |
| [`net::http::headers`](net/http/headers.md) | `net::http::headers(arg1)` |  |
| [`net::http::is_ok`](net/http/is_ok.md) | `net::http::is_ok(arg1)` |  |
| [`net::http::status`](net/http/status.md) | `net::http::status(url)` |  |
| [`net::interface::is_up`](net/interface/is_up.md) | `net::interface::is_up(arg1)` |  |
| [`net::interface::list`](net/interface/list.md) | `net::interface::list(arg2)` |  |
| [`net::interface::speed`](net/interface/speed.md) | `net::interface::speed()` |  |
| [`net::interface::stat`](net/interface/stat.md) | `net::interface::stat(s, interface)` |  |
| [`net::interface::stat::rx`](net/interface/stat/rx.md) | `net::interface::stat::rx()` |  |
| [`net::interface::stat::tx`](net/interface/stat/tx.md) | `net::interface::stat::tx()` |  |
| [`net::ip::all`](net/ip/all.md) | `net::ip::all(arg2)` |  |
| [`net::ip::geo`](net/ip/geo.md) | `net::ip::geo([ip], , (omit, for, public, IP))` |  |
| [`net::ip::is_loopback`](net/ip/is_loopback.md) | `net::ip::is_loopback(arg1)` |  |
| [`net::ip::is_private`](net/ip/is_private.md) | `net::ip::is_private(arg1)` |  |
| [`net::ip::is_valid_v4`](net/ip/is_valid_v4.md) | `net::ip::is_valid_v4(arg1)` |  |
| [`net::ip::is_valid_v6`](net/ip/is_valid_v6.md) | `net::ip::is_valid_v6(arg1)` |  |
| [`net::ip::local`](net/ip/local.md) | `net::ip::local(arg2)` |  |
| [`net::ip::public`](net/ip/public.md) | `net::ip::public()` |  |
| [`net::is_online`](net/is_online.md) | `net::is_online()` |  |
| [`net::mac`](net/mac.md) | `net::mac(interface)` |  |
| [`net::ping`](net/ping.md) | `net::ping(host, [count])` |  |
| [`net::port::is_open`](net/port/is_open.md) | `net::port::is_open(host, port, [timeout])` |  |
| [`net::port::scan`](net/port/scan.md) | `net::port::scan(host, [start_port], [end_port])` |  |
| [`net::port::wait`](net/port/wait.md) | `net::port::wait(host, port, [timeout_seconds], [interval])` |  |
| [`net::resolve`](net/resolve.md) | `net::resolve(hostname)` |  |
| [`net::resolve::reverse`](net/resolve/reverse.md) | `net::resolve::reverse(ip)` |  |
| [`net::whois`](net/whois.md) | `net::whois(arg1)` |  |

