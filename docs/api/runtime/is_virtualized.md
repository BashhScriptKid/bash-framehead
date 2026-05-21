# `runtime::is_virtualized`

**Signature:** `runtime::is_virtualized()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_virtualized() {
  if [[ $(runtime::os) == "linux" ]]; then
    if [[ -f /proc/cpuinfo ]]; then
      grep -q "hypervisor" /proc/cpuinfo && return 0
    fi
    if [[ -f /sys/class/dmi/id/product_name ]]; then
      local product
      product=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
      [[ "$product" =~ (VirtualBox|VMware|KVM|QEMU|Xen|Hyper-V) ]] && return 0
    fi
  fi
  return 1
}
```

