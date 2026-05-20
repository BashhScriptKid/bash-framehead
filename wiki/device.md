# `device`

Block and character device inspection, classification, listing, and I/O operations. **25 functions.** No `::fast` variants.

---

## Inspection

| Function | Description |
|----------|-------------|
| `device::exists` | Check if device exists (block or character) |
| `device::is_device` | Check if path is a character device |
| `device::is_block` | Check if path is a block device |
| `device::is_readable` | Check if device is readable |
| `device::is_writeable` | Check if device is writable |
| `device::has_processes` | Check if device has open file handles (requires `lsof`) |
| `device::is_occupied` | Check if device is occupied via `/proc` (no `lsof` needed) |
| `device::is_mounted` | Check if a block device is mounted |
| `device::is_loop` | Check if device is a loop device |
| `device::is_ram` | Check if device is a RAM disk |
| `device::is_virtual` | Check if device is a virtual/pseudo device |

```bash
if device::is_block "/dev/sda"; then
    echo "It's a block device"
fi
device::is_mounted "/dev/sda1" && echo "Already mounted"
```

## Classification

| Function | Description |
|----------|-------------|
| `device::type` | Return device type string: `block`, `char`, `loop`, `ram`, `disk`, `partition`, `nvme`, `virtual`, `tty`, `pty`, `usb`, `optical`, `unknown` |
| `device::number` | Return major:minor device number |
| `device::filesystem` | Return filesystem type (requires `blkid` or `diskutil`) |
| `device::size_bytes` | Return size of a block device in bytes |
| `device::size_mb` | Return size of a block device in MB |
| `device::mount_point` | Return mount point (empty if not mounted) |

```bash
device::type "/dev/sda"               # → disk
device::type "/dev/sda1"              # → partition
device::filesystem "/dev/sda1"        # → ext4
device::size_mb "/dev/sda1"           # → 512000
device::mount_point "/dev/sda1"       # → /home
```

## Listing

| Function | Description |
|----------|-------------|
| `device::list::block` | List all block devices |
| `device::list::char` | List all character devices |
| `device::list::tty` | List all TTY devices |
| `device::list::loop` | List all loop devices |
| `device::list::mounted` | List mounted devices with their mount points |

```bash
device::list::block     # Lists all /dev/sd*, /dev/nvme*, etc.
device::list::mounted   # Shows device → mount point mappings
```

## Special Devices

| Function | Description |
|----------|-------------|
| `device::zero` | Write n bytes of zeros to a device or file (wraps `/dev/zero`). **Destructive** |
| `device::random` | Read n random bytes from `/dev/urandom` |
| `device::null_ok` | Check if `/dev/null` is functional (sanity check) |

```bash
# Write 1KB of zeros to a file
device::zero "./empty.dat" 1024

# Read 32 random bytes
device::random 32 | xxd
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `blkid` (for filesystem detection), `lsof` (for process checking), `stat` (for device numbers)
