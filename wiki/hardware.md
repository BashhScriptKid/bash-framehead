# `hardware`

System hardware detection — CPU, GPU, RAM, disk, partitions, swap, and battery information. **36 functions.** No `::fast` variants.

---

## CPU

| Function | Description |
|----------|-------------|
| `hardware::cpu::name` | Return CPU model name |
| `hardware::cpu::core_count::physical` | Number of physical CPU cores |
| `hardware::cpu::core_count::logical` | Number of logical CPU cores (with hyperthreading) |
| `hardware::cpu::core_count::total` | Alias for logical core count |
| `hardware::cpu::thread_count` | Alias for logical core count |
| `hardware::cpu::frequencyMHz` | Current CPU frequency in MHz |
| `hardware::cpu::temp` | CPU temperature (if available) |

```bash
hardware::cpu::name                # → "Intel(R) Core(TM) i7-10750H"
hardware::cpu::core_count::physical # → 6
hardware::cpu::core_count::logical  # → 12
hardware::cpu::temp                 # → 45.0 (in °C)
```

## GPU

| Function | Description |
|----------|-------------|
| `hardware::gpu` | Return GPU name |
| `hardware::gpu::vramMB` | Return VRAM in MB |

```bash
hardware::gpu          # → "NVIDIA GeForce RTX 3070"
hardware::gpu::vramMB  # → 8192
```

## RAM

| Function | Description |
|----------|-------------|
| `hardware::ram::totalSpaceMB` | Total RAM in MB |
| `hardware::ram::usedSpaceMB` | Used RAM in MB |
| `hardware::ram::freeSpaceMB` | Free RAM in MB |
| `hardware::ram::percentage` | RAM usage percentage |

```bash
hardware::ram::totalSpaceMB  # → 16384
hardware::ram::usedSpaceMB   # → 8192
hardware::ram::percentage    # → 50
```

## Disk

| Function | Description |
|----------|-------------|
| `hardware::disk::devices` | List disk device paths |
| `hardware::disk::count::total` | Total number of disks |
| `hardware::disk::count::physical` | Number of physical disks |
| `hardware::disk::count::virtual` | Number of virtual disks |
| `hardware::disk::name` | Return disk model name |

## Partitions

All partition functions accept an optional mount point argument (default: `/`).

| Function | Description |
|----------|-------------|
| `hardware::partition::count` | Number of partitions |
| `hardware::partition::info` | Human-readable disk info for a mount point |
| `hardware::partition::totalSpaceMB` | Total partition space in MB |
| `hardware::partition::usedSpaceMB` | Used partition space in MB |
| `hardware::partition::freeSpaceMB` | Free partition space in MB |
| `hardware::partition::usagePercent` | Partition usage percentage |

```bash
hardware::partition::info "/home"  # → /dev/sda2 500G 200G 300G 40%
hardware::partition::usagePercent "/var"  # → 75
```

## Swap

| Function | Description |
|----------|-------------|
| `hardware::swap::totalSpaceMB` | Total swap space in MB |
| `hardware::swap::usedSpaceMB` | Used swap space in MB |
| `hardware::swap::freeSpaceMB` | Free swap space in MB |

## Battery

| Function | Description |
|----------|-------------|
| `hardware::battery::present` | Check if a battery is present |
| `hardware::battery::percentage` | Current battery percentage |
| `hardware::battery::is_charging` | Check if battery is charging |
| `hardware::battery::status` | Battery status string (charging/discharging/full) |
| `hardware::battery::time_remaining` | Estimated time remaining |
| `hardware::battery::capacity` | Battery design capacity percentage |
| `hardware::battery::health` | Battery health status |

```bash
if hardware::battery::present; then
    echo "$(hardware::battery::percentage)% $(hardware::battery::status)"
fi
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `lscpu`, `lspci`, `nvidia-smi` (for GPU), `acpi` or `/sys/class/power_supply` (for battery)
