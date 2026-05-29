#!/usr/bin/env bash
# device.sh — bash-frameheader device lib
# Requires: runtime.sh (runtime::os, runtime::has_command)

# --- INSPECTION ---

# Check if path is any kind of device (block or character)
device::is_device() {
		[[ -b "$1" || -c "$1" ]]
}

# Check if path is a character device
device::is_device::char() {
		[[ -c "$1" ]]
}

# Check if path is a block device
device::is_device::block() {
		[[ -b "$1" ]]
}

# Backward-compatible alias
device::is_block() {
		device::is_device::block "$@"
}

# Check if device is writable
device::is_writeable() {
		[[ -w "$1" ]]
}

# Check if device is readable
device::is_readable() {
		[[ -r "$1" ]]
}

# Check if device exists (block or character)
device::exists() {
		[[ -b "$1" || -c "$1" ]]
}

# Check if device has open file handles via lsof
device::has_processes() {
		runtime::has_command lsof || return 1
		lsof -t "$1" >/dev/null 2>&1
}

# Check if device is occupied via /proc (no lsof needed)
device::is_occupied() {
		find /proc/[0-9]*/fd -lname "*${1#/dev/}" 2>/dev/null | head -1 | grep -q .
}

# Check if a block device is mounted
device::is_mounted() {
		grep -q "^$1 " /proc/mounts 2>/dev/null \
				|| grep -q " $1 " /proc/mounts 2>/dev/null
}

# Check if device is a loop device
device::is_loop() {
		[[ "$1" == /dev/loop* ]]
}

# Check if device is a RAM disk
device::is_ram() {
		[[ "$1" == /dev/ram* || "$1" == /dev/zram* ]]
}

# Check if device is a virtual/pseudo device
device::is_virtual() {
		case "$1" in
				/dev/null | /dev/zero | /dev/full | /dev/random | \
				/dev/urandom | /dev/stdin | /dev/stdout | /dev/stderr | \
				/dev/fd/* | /dev/ptmx | /dev/tty*)
						return 0 ;;
				*)
						return 1 ;;
		esac
}

# --- CLASSIFICATION ---

# Returns the type of a device as a string
# Possible returns: block, char, loop, ram, disk, partition, nvme,
#                   virtual, tty, pty, usb, optical, unknown
device::type() {
		local dev="$1"
		local base="${dev##*/}"

		# Virtual/pseudo devices first
		device::is_virtual "$dev" && echo "virtual"   && return
		device::is_loop "$dev"    && echo "loop"      && return
		device::is_ram "$dev"     && echo "ram"       && return

		# TTY / PTY
		[[ "$dev" == /dev/tty*  ]] && echo "tty" && return
		[[ "$dev" == /dev/pts/* ]] && echo "pty" && return

		# NVMe
		[[ "$base" =~ ^nvme[0-9]+n[0-9]+p[0-9]+$ ]] && echo "partition" && return
		[[ "$base" =~ ^nvme[0-9]+n[0-9]+$        ]] && echo "nvme"      && return

		# SD/SAS/SATA partitions vs disks
		[[ "$base" =~ ^sd[a-z]+[0-9]+$  ]] && echo "partition" && return
		[[ "$base" =~ ^sd[a-z]+$        ]] && echo "disk"      && return

		# MMC / eMMC
		[[ "$base" =~ ^mmcblk[0-9]+p[0-9]+$ ]] && echo "partition" && return
		[[ "$base" =~ ^mmcblk[0-9]+$        ]] && echo "disk"      && return

		# IDE (legacy)
		[[ "$base" =~ ^hd[a-z]+[0-9]+$ ]] && echo "partition" && return
		[[ "$base" =~ ^hd[a-z]+$       ]] && echo "disk"      && return

		# Optical
		[[ "$base" =~ ^sr[0-9]+$  ]] && echo "optical" && return
		[[ "$base" =~ ^cd[a-z]+$  ]] && echo "optical" && return

		# USB block devices (often shows as sdX — covered above, but flag specific paths)
		[[ "$dev" == /dev/bus/usb/* ]] && echo "usb" && return

		# Generic character vs block fallback
		device::is_device::block "$dev" && echo "block" && return
		device::is_device::char  "$dev" && echo "char"  && return

		echo "unknown"
}

# Returns the major:minor device number
device::number() {
		local dev="$1"
		if runtime::has_command stat; then
				case "$(runtime::os)" in
				linux|wsl|cygwin|mingw)
						stat -c '%t:%T' "$dev" 2>/dev/null | \
								awk -F: '{ printf "%d:%d\n", strtonum("0x"$1), strtonum("0x"$2) }'
						;;
				darwin)
						stat -f '%Hr:%Lr' "$dev" 2>/dev/null
						;;
				*)
						echo "unknown"
						;;
				esac
		else
				echo "unknown"
		fi
}

# Returns the filesystem on a block device (if mounted or detectable)
# Requires: blkid (Linux) or diskutil (macOS)
device::filesystem() {
		local dev="$1"
		case "$(runtime::os)" in
		linux|wsl)
				if runtime::has_command blkid; then
						blkid -o value -s TYPE "$dev" 2>/dev/null || echo "unknown"
				else
						echo "unknown"
				fi
				;;
		darwin)
				diskutil info "$dev" 2>/dev/null \
						| awk -F': +' '/Type \(Bundle\)/ { print $2 }' || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

# Returns the size of a block device in bytes
device::size_bytes() {
		local dev="$1"
		case "$(runtime::os)" in
		linux|wsl)
				if [[ -r "/sys/block/${dev##*/}/size" ]]; then
						# /sys/block reports 512-byte sectors
						echo $(( $(cat "/sys/block/${dev##*/}/size") * 512 ))
				elif runtime::has_command blockdev; then
						blockdev --getsize64 "$dev" 2>/dev/null || echo "unknown"
				else
						echo "unknown"
				fi
				;;
		darwin)
				diskutil info "$dev" 2>/dev/null \
						| awk -F': +' '/Disk Size/ { match($2, /[0-9]+/, a); print a[0] }' \
						|| echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

# Returns the size of a block device in MB
device::size_mb() {
		local bytes
		bytes=$(device::size_bytes "$1")
		[[ "$bytes" == "unknown" ]] && echo "unknown" && return
		echo $(( bytes / 1024 / 1024 ))
}

# Returns the mount point of a block device (empty if not mounted)
device::mount_point() {
		local dev="$1"
		case "$(runtime::os)" in
		linux|wsl)
				grep "^$dev " /proc/mounts 2>/dev/null | awk '{print $2}' | head -1
				;;
		darwin)
				diskutil info "$dev" 2>/dev/null \
						| awk -F': +' '/Mount Point/ { print $2 }'
				;;
		*)
				echo ""
				;;
		esac
}

# --- LISTING ---

# List all block devices
device::list::block() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -dno NAME 2>/dev/null | sed 's/^/\/dev\//' | grep -v loop
				;;
		darwin)
				diskutil list 2>/dev/null | awk '/^\/dev\// { print $1 }'
				;;
		*)
				echo "unknown"
				;;
		esac
}

# List all character devices
device::list::char() {
		find /dev -maxdepth 1 -type c 2>/dev/null | sort
}

# List all TTY devices
device::list::tty() {
		find /dev -maxdepth 1 -name 'tty*' -type c 2>/dev/null | sort
}

# List all loop devices
device::list::loop() {
		find /dev -maxdepth 1 -name 'loop*' -type b 2>/dev/null | sort
}

# List mounted devices with their mount points
device::list::mounted() {
		case "$(runtime::os)" in
		linux|wsl)
				grep '^/dev/' /proc/mounts 2>/dev/null | awk '{print $1, $2}'
				;;
		darwin)
				mount 2>/dev/null | awk '/^\/dev\// { print $1, $3 }'
				;;
		*)
				echo "unknown"
				;;
		esac
}

# --- SPECIAL DEVICES ---

# Write n bytes of zeros to a device or file (wraps /dev/zero)
# Usage: device::zero target [bytes]
# WARNING: Destructive — use with care
device::zero() {
		local target="$1" bytes="${2:-16}"
		if [[ -n "$bytes" ]]; then
				dd if=/dev/zero of="$target" bs=1 count="$bytes" 2>/dev/null
		else
				dd if=/dev/zero of="$target" 2>/dev/null
		fi
}

# Read n random bytes from /dev/urandom
# Usage: device::random [bytes]
device::random() {
		local bytes="${1:-16}"
		dd if=/dev/urandom bs=1 count="$bytes" 2>/dev/null | od -An -tx1 | tr -d ' \n'
		echo
}

# Check if /dev/null is functional (sanity check)
device::null_ok() {
		echo "" > /dev/null 2>&1
}

# --- BLOCK METADATA ---

device::read::model() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/device/model" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::vendor() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/device/vendor" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::serial() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/serial" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::firmware() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/device/rev" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::sector_size() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/queue/physical_block_size" 2>/dev/null || echo "unknown"
}

device::read::queue_depth() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/queue/nr_requests" 2>/dev/null || echo "unknown"
}

device::read::scheduler() {
		local _dev="$1" _base="${1##*/}"
		local _sched
		_sched=$(cat "/sys/block/${_base}/queue/scheduler" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "$_sched" | grep -oP '\[.*?\]' | tr -d '[]'
}

device::read::rotational() {
		local _dev="$1" _base="${1##*/}"
		local _val
		_val=$(cat "/sys/block/${_base}/queue/rotational" 2>/dev/null) || { echo "unknown"; return 1; }
		[[ "$_val" == "1" ]] && echo "1" || echo "0"
}

device::read::io_stat() {
		local _dev="$1" _base="${1##*/}"
		local _stat
		_stat=$(cat "/sys/block/${_base}/stat" 2>/dev/null) || { echo "unknown"; return 1; }
		local _reads _writes _ios
		_reads=$(awk '{print $1}' <<< "$_stat")
		_writes=$(awk '{print $5}' <<< "$_stat")
		_ios=$(awk '{print $9}' <<< "$_stat")
		printf 'reads=%s writes=%s ios=%s\n' "$_reads" "$_writes" "$_ios"
}

# --- USB METADATA ---

device::read::usb::vendor_id() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/idVendor" 2>/dev/null || echo "unknown"
}

device::read::usb::product_id() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/idProduct" 2>/dev/null || echo "unknown"
}

device::read::usb::speed() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/speed" 2>/dev/null || echo "unknown"
}

device::read::usb::manufacturer() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/manufacturer" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::usb::product() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/product" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::usb::serial() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/serial" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

device::read::usb::driver() {
		local _dev="$1"
		local _link
		_link=$(readlink "/sys/bus/usb/devices/${_dev}/driver" 2>/dev/null) || { echo "unknown"; return 1; }
		basename "$_link"
}

device::read::usb::max_power() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/bMaxPower" 2>/dev/null || echo "unknown"
}

device::list::usb() {
		local _dir _id
		for _dir in /sys/bus/usb/devices/[0-9]*; do
				[[ -d "$_dir" ]] || continue
				_id=$(cat "$_dir/idVendor" 2>/dev/null) || continue
				basename "$_dir"
		done
}

device::list::usb::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir _id
		for _dir in /sys/bus/usb/devices/[0-9]*; do
				[[ -d "$_dir" ]] || continue
				_id=$(cat "$_dir/idVendor" 2>/dev/null) || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}

# --- EXISTING LISTER FAST VARIANTS ---

device::list::block::fast() {
		local -n _ref="$1"
		local -a _out=()
		while IFS= read -r _line; do
				_out+=("$_line")
		done < <(device::list::block)
		_ref=("${_out[@]}")
}

device::list::char::fast() {
		local -n _ref="$1"
		local -a _out=()
		while IFS= read -r _line; do
				_out+=("$_line")
		done < <(device::list::char)
		_ref=("${_out[@]}")
}

device::list::tty::fast() {
		local -n _ref="$1"
		local -a _out=()
		while IFS= read -r _line; do
				_out+=("$_line")
		done < <(device::list::tty)
		_ref=("${_out[@]}")
}

device::list::loop::fast() {
		local -n _ref="$1"
		local -a _out=()
		while IFS= read -r _line; do
				_out+=("$_line")
		done < <(device::list::loop)
		_ref=("${_out[@]}")
}

device::list::mounted::fast() {
		local -n _ref="$1"
		local -a _out=()
		while IFS= read -r _line; do
				_out+=("$_line")
		done < <(device::list::mounted)
		_ref=("${_out[@]}")
}

# --- FRAMEBUFFER ---

device::fb::name() {
		local _fb="${1:-fb0}"
		cat "/sys/class/graphics/${_fb}/name" 2>/dev/null || echo "unknown"
}

device::fb::resolution() {
		local _fb="${1:-fb0}"
		local _size
		_size=$(cat "/sys/class/graphics/${_fb}/virtual_size" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "${_size//,/x}"
}

device::fb::bpp() {
		local _fb="${1:-fb0}"
		cat "/sys/class/graphics/${_fb}/bits_per_pixel" 2>/dev/null || echo "unknown"
}

device::fb::stride() {
		local _fb="${1:-fb0}"
		cat "/sys/class/graphics/${_fb}/stride" 2>/dev/null || echo "unknown"
}

device::fb::mode() {
		local _fb="${1:-fb0}"
		cat "/sys/class/graphics/${_fb}/mode" 2>/dev/null || echo "unknown"
}

device::fb::info() {
		local _fb="${1:-fb0}"
		if runtime::has_command fbset; then
				fbset -i -fb "/dev/${_fb}" 2>/dev/null || echo "unknown"
		else
				echo "unknown"
		fi
}

device::fb::capture() {
		local _fb="${1:-fb0}"
		local _sysfs="/sys/class/graphics/${_fb}"
		local _size _width _height _bpp _bytespp
		_size=$(cat "$_sysfs/virtual_size" 2>/dev/null) || { echo "device::fb::capture: cannot read framebuffer size" >&2; return 1; }
		_width="${_size%%,*}"
		_height="${_size##*,}"
		_bpp=$(cat "$_sysfs/bits_per_pixel" 2>/dev/null) || _bpp=32
		_bytespp=$((_bpp / 8))
		local _pixels=$((_width * _height))
		local _bytes=$((_pixels * _bytespp))
		printf "P6\n%d %d\n255\n" "$_width" "$_height"
		dd if="/dev/${_fb}" bs=1 count="$_bytes" 2>/dev/null
}

device::list::fb() {
		local _dir
		for _dir in /sys/class/graphics/fb*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}

device::list::fb::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/graphics/fb*; do
				[[ -d "$_dir" ]] || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}

# --- GPU / DRM ---

device::read::gpu::name() {
		local _card="${1:-card0}"
		cat "/sys/class/drm/${_card}/device/product_name" 2>/dev/null || \
				cat "/sys/class/drm/${_card}/device/uevent" 2>/dev/null | grep -oP 'PCI_ID=\K.*' || \
				echo "unknown"
}

device::read::gpu::temp() {
		local _card="${1:-card0}"
		local _temp
		_temp=$(cat "/sys/class/drm/${_card}/device/hwmon/hwmon*/temp1_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo $((_temp / 1000))
}

device::read::gpu::vram() {
		local _card="${1:-card0}"
		local _bytes
		_bytes=$(cat "/sys/class/drm/${_card}/device/mem_info_vram_total" 2>/dev/null) || { echo "unknown"; return 1; }
		if (( _bytes >= 1073741824 )); then
				printf '%.1fGB' "$((_bytes / 1073741824))"
		elif (( _bytes >= 1048576 )); then
				printf '%.0fMB' "$((_bytes / 1048576))"
		else
				echo "${_bytes}B"
		fi
}

device::read::gpu::freq() {
		local _card="${1:-card0}"
		local _freq
		_freq=$(cat "/sys/class/drm/${_card}/device/pp_dpm_sclk" 2>/dev/null | grep '\*' | awk '{print $2}') || \
		_freq=$(cat "/sys/class/drm/${_card}/gt_cur_freq_mhz" 2>/dev/null) || \
		{ echo "unknown"; return 1; }
		echo "$_freq"
}

device::list::gpu() {
		local _dir
		for _dir in /sys/class/drm/card[0-9]*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}

device::list::gpu::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/drm/card[0-9]*; do
				[[ -d "$_dir" ]] || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}

# --- AUDIO / ALSA ---

device::read::alsa::cards() {
		if [[ -f /proc/asound/cards ]]; then
				awk '/^[[:space:]]*[0-9]+/ {printf "%s %s\n", $1, $2}' /proc/asound/cards
		else
				echo "unknown"
		fi
}

device::read::alsa::card_info() {
		local _card="$1"
		local _dir="/proc/asound/card${_card}"
		[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
		local _stream _pcm
		for _stream in "$_dir"/pcm*p; do
				[[ -d "$_stream" ]] || continue
				_pcm=$(cat "$_stream/info" 2>/dev/null | grep -E '^card|^id|^name' | awk -F: '{gsub(/^[[:space:]]+/,"",$2); printf "%s=%s ", $1, $2}')
				[[ -n "$_pcm" ]] && echo "$_pcm"
		done
}

device::list::alsa() {
		if [[ -f /proc/asound/cards ]]; then
				awk '/^[[:space:]]*[0-9]+/ {print $1}' /proc/asound/cards
		else
				echo ""
		fi
}

device::list::alsa::fast() {
		local -n _ref="$1"
		local -a _out=()
		if [[ -f /proc/asound/cards ]]; then
				while IFS= read -r _line; do
						[[ -n "$_line" ]] && _out+=("$_line")
				done < <(awk '/^[[:space:]]*[0-9]+/ {print $1}' /proc/asound/cards)
		fi
		_ref=("${_out[@]}")
}

# --- INPUT DEVICES ---

device::read::input::devices() {
		if [[ -f /proc/bus/input/devices ]]; then
				awk -F= '/^N:/{name=$2} /^H:/{handlers=$2} /^B: EV/{ev=$2} /^$/{if(name)printf "%-40s handlers=%-20s ev=%s\n",name,handlers,ev; name=""; handlers=""; ev=""}' /proc/bus/input/devices
		else
				echo "unknown"
		fi
}

device::read::input::info() {
		local _pattern="$1"
		if [[ -f /proc/bus/input/devices ]]; then
				awk -v pat="$_pattern" -F= '
				/^N:/{name=$2; buf=$0}
				/^H:/{handlers=$2; buf=buf"\n"$0}
				/^B: EV/{ev=$2; buf=buf"\n"$0}
				/^B: KEY/{key=$2; buf=buf"\n"$0}
				/^B: ABS/{abs=$2; buf=buf"\n"$0}
				/^B: REL/{rel=$2; buf=buf"\n"$0}
				/^S:/{sysfs=$2; buf=buf"\n"$0}
				/^$/{if(name ~ pat || handlers ~ pat)print buf"\n"; buf=""}
				' /proc/bus/input/devices
		else
				echo "unknown"
		fi
}

device::list::input() {
		if [[ -f /proc/bus/input/devices ]]; then
				awk -F= '/^N:/{gsub(/^[[:space:]]+/,"",$2); print $2}' /proc/bus/input/devices
		else
				echo ""
		fi
}

device::list::input::fast() {
		local -n _ref="$1"
		local -a _out=()
		if [[ -f /proc/bus/input/devices ]]; then
				while IFS= read -r _line; do
						[[ -n "$_line" ]] && _out+=("$_line")
				done < <(awk -F= '/^N:/{gsub(/^[[:space:]]+/,"",$2); print $2}' /proc/bus/input/devices)
		fi
		_ref=("${_out[@]}")
}

# --- INPUT DEVICE DISCOVERY ---

device::input::find::name() {
		local _pattern="$1"
		awk -v pat="$_pattern" '
		/^N:/{name=$0; sub(/^N: Name=/, "", name)}
		/^H:/{handlers=$0}
		/^$/{if(name ~ pat) {
			match(handlers, /event[0-9]+/)
			if (RSTART > 0) print substr(handlers, RSTART, RLENGTH)
		}}
		' /proc/bus/input/devices 2>/dev/null | head -1
}

device::input::find::capability() {
		local _cap="$1"
		local _bit
		case "$_cap" in
				key) _bit=1 ;;   # EV_KEY = bit 1
				rel) _bit=2 ;;   # EV_REL = bit 2
				abs) _bit=3 ;;   # EV_ABS = bit 3
				*)   echo ""; return 1 ;;
		esac
		awk -v bit="$_bit" '
		/^H:/{handlers=$0}
		/^B: EV/{
			ev_hex=$2
			# Parse hex bitmask
			ev_val = 0
			for (i=1; i<=length(ev_hex); i++) {
				c = substr(ev_hex, i, 1)
				if (c >= "0" && c <= "9") v = c + 0
				else if (c >= "a" && c <= "f") v = 10 + (index("abcdef", c) - 1)
				else if (c >= "A" && c <= "F") v = 10 + (index("ABCDEF", c) - 1)
				else v = 0
				ev_val = ev_val * 16 + v
			}
			# Check if bit is set
			mask = 2 ^ bit
			if (and(ev_val, mask)) {
				match(handlers, /event[0-9]+/)
				if (RSTART > 0) print substr(handlers, RSTART, RLENGTH)
			}
		}
		' /proc/bus/input/devices 2>/dev/null | head -1
}

device::input::find::id() {
		local _id="$1"
		local _link
		_link="/dev/input/by-id/${_id}"
		if [[ -L "$_link" ]]; then
				local _target
				_target=$(readlink "$_link") || { echo ""; return 1; }
				basename "$_target"
				return
		fi
		_link="/dev/input/by-path/${_id}"
		if [[ -L "$_link" ]]; then
				local _target
				_target=$(readlink "$_link") || { echo ""; return 1; }
				basename "$_target"
				return
		fi
		echo ""
		return 1
}

# --- EVENT CONSTANTS ---

readonly EV_SYN=0
readonly EV_KEY=1
readonly EV_REL=2
readonly EV_ABS=3
readonly EV_MSC=4
readonly EV_SW=5
readonly EV_LED=17
readonly EV_SND=18
readonly EV_REP=20
readonly EV_FF=21

readonly SYN_REPORT=0
readonly SYN_MT_REPORT=1

readonly REL_X=0
readonly REL_Y=1
readonly REL_Z=2
readonly REL_RX=3
readonly REL_RY=4
readonly REL_RZ=5
readonly REL_HWHEEL=6
readonly REL_DIAL=7
readonly REL_WHEEL=8

readonly ABS_X=0
readonly ABS_Y=1
readonly ABS_Z=2
readonly ABS_RX=3
readonly ABS_RY=4
readonly ABS_RZ=5
readonly ABS_THROTTLE=6
readonly ABS_RUDDER=7
readonly ABS_WHEEL=8
readonly ABS_GAS=9
readonly ABS_BRAKE=10
readonly ABS_PRESSURE=24
readonly ABS_DISTANCE=25
readonly ABS_TILT_X=26
readonly ABS_TILT_Y=27
readonly ABS_TOOL_WIDTH=28

readonly BTN_LEFT=0x110
readonly BTN_RIGHT=0x111
readonly BTN_MIDDLE=0x112
readonly BTN_SIDE=0x113
readonly BTN_EXTRA=0x114
readonly BTN_FORWARD=0x115
readonly BTN_BACK=0x116
readonly BTN_TASK=0x117
readonly BTN_TOOL_PEN=0x140
readonly BTN_TOOL_RUBBER=0x141
readonly BTN_TOOL_BRUSH=0x142
readonly BTN_TOOL_PENCIL=0x143
readonly BTN_TOOL_AIRBRUSH=0x144
readonly BTN_TOOL_FINGER=0x145
readonly BTN_TOOL_MOUSE=0x146
readonly BTN_TOUCH=0x14a
readonly BTN_STYLUS=0x14b
readonly BTN_STYLUS2=0x14c

# --- EVENT PRIMITIVES ---

# Parse raw 24-byte evdev struct into type/code/value
# Usage: device::event::raw::parse "hex bytes..."
# Sets _ev_type, _ev_code, _ev_value
device::event::raw::parse() {
		local -a _bytes
		read -ra _bytes <<< "$1"
		_ev_type=$((16#${_bytes[16]} + 16#${_bytes[17]} * 256))
		_ev_code=$((16#${_bytes[18]} + 16#${_bytes[19]} * 256))
		_ev_value=$((16#${_bytes[20]} + 16#${_bytes[21]} * 256 + 16#${_bytes[22]} * 65536 + 16#${_bytes[23]} * 16777216))
}

# Read one raw event from device, return hex bytes
device::event::raw::read() {
		od -An -tx1 -N24 "/dev/input/$1" 2>/dev/null
}

# Read one event, return type code value
device::event::read() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		_raw=$(device::event::raw::read "$_dev") || { echo "unknown"; return 1; }
		device::event::raw::parse "$_raw"
		printf '%d %d %d' "$_ev_type" "$_ev_code" "$_ev_value"
}

# Read a complete event frame (all events until SYN_REPORT)
# Returns one line per event: "type code value"
device::event::read::frame() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				printf '%d %d %d\n' "$_ev_type" "$_ev_code" "$_ev_value"
				# SYN_REPORT = type 0, code 0
				(( _ev_type == 0 && _ev_code == 0 )) && return 0
		done
}

# Block until key event, return key code (only on press, not release)
device::event::wait::key() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				(( _ev_type == EV_KEY && _ev_value == 1 )) && { echo "$_ev_code"; return 0; }
		done
}

# Block until any event, return type code value
device::event::wait::any() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		_raw=$(device::event::raw::read "$_dev") || { echo "unknown"; return 1; }
		device::event::raw::parse "$_raw"
		printf '%d %d %d' "$_ev_type" "$_ev_code" "$_ev_value"
}

# --- MOUSE ---

# Read relative mouse deltas until SYN_REPORT, return accumulated dx dy
device::input::mouse::read() {
		local _dev="$1"
		local _dx=0 _dy=0 _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_REL)
								case "$_ev_code" in
										$REL_X) ((_dx += _ev_value)) ;;
										$REL_Y) ((_dy += _ev_value)) ;;
								esac
								;;
						$EV_SYN) break ;;
				esac
		done
		printf '%d %d' "$_dx" "$_dy"
}

# Read mouse button state until SYN_REPORT, return button press/release
device::input::mouse::button() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								# BTN_LEFT=0x110, BTN_RIGHT=0x111, BTN_MIDDLE=0x112
								if (( _ev_code >= 0x110 && _ev_code <= 0x117 )); then
										local _name
										case "$_ev_code" in
												0x110) _name="left" ;;
												0x111) _name="right" ;;
												0x112) _name="middle" ;;
												0x113) _name="side" ;;
												0x114) _name="extra" ;;
												*) _name="$_ev_code" ;;
										esac
										printf '%s %s' "$_name" "$([[ $_ev_value -eq 1 ]] && echo press || echo release)"
										return 0
								fi
								;;
						$EV_SYN) break ;;
				esac
		done
}

# --- TABLET / TOUCHPAD ---

# Read absolute position until SYN_REPORT, return x y [pressure] [tilt_x] [tilt_y]
device::input::tablet::read() {
		local _dev="$1"
		local _x=0 _y=0 _pressure=0 _tilt_x=0 _tilt_y=0 _has_pressure=0 _has_tilt=0
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_ABS)
								case "$_ev_code" in
										$ABS_X) _x=$_ev_value ;;
										$ABS_Y) _y=$_ev_value ;;
										$ABS_PRESSURE) _pressure=$_ev_value; _has_pressure=1 ;;
										$ABS_TILT_X) _tilt_x=$_ev_value; _has_tilt=1 ;;
										$ABS_TILT_Y) _tilt_y=$_ev_value; _has_tilt=1 ;;
								esac
								;;
						$EV_SYN) break ;;
				esac
		done
		if (( _has_tilt )); then
				printf '%d %d %d %d %d' "$_x" "$_y" "$_pressure" "$_tilt_x" "$_tilt_y"
		elif (( _has_pressure )); then
				printf '%d %d %d' "$_x" "$_y" "$_pressure"
		else
				printf '%d %d' "$_x" "$_y"
		fi
}

# Read touchpad gesture (BTN_TOOL_FINGER + ABS_X/ABS_Y + ABS_PRESSURE)
device::input::touchpad::read() {
		local _dev="$1"
		local _x=0 _y=0 _pressure=0 _touching=0
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								case "$_ev_code" in
										$BTN_TOUCH) _touching=$_ev_value ;;
										$BTN_TOOL_FINGER) _touching=$_ev_value ;;
								esac
								;;
						$EV_ABS)
								case "$_ev_code" in
										$ABS_X) _x=$_ev_value ;;
										$ABS_Y) _y=$_ev_value ;;
										$ABS_PRESSURE) _pressure=$_ev_value ;;
								esac
								;;
						$EV_SYN) break ;;
				esac
		done
		printf '%d %d %d %d' "$_touching" "$_x" "$_y" "$_pressure"
}

# --- KEYBOARD ---

# Read keyboard event until SYN_REPORT, return key state
device::input::keyboard::state::keycode() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								local _state
								case "$_ev_value" in
										0) _state="release" ;;
										1) _state="press" ;;
										2) _state="repeat" ;;
										*) _state="$_ev_value" ;;
								esac
								printf '%d %s' "$_ev_code" "$_state"
								return 0
								;;
						$EV_SYN) break ;;
				esac
		done
}

# Read keyboard event, return key name instead of code
device::input::keyboard::state::keyname() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								local _name _state
								_name=$(device::input::keyname "$_ev_code")
								case "$_ev_value" in
										0) _state="release" ;;
										1) _state="press" ;;
										2) _state="repeat" ;;
										*) _state="$_ev_value" ;;
								esac
								printf '%s %s' "$_name" "$_state"
								return 0
								;;
						$EV_SYN) break ;;
				esac
		done
}

# Convert key code to name
device::input::keyname() {
		local _code="$1"
		case "$_code" in
				1) echo "escape" ;;
				2) echo "1" ;; 3) echo "2" ;; 4) echo "3" ;; 5) echo "4" ;;
				6) echo "5" ;; 7) echo "6" ;; 8) echo "7" ;; 9) echo "8" ;;
				10) echo "9" ;; 11) echo "0" ;;
				12) echo "minus" ;; 13) echo "equal" ;; 14) echo "backspace" ;;
				15) echo "tab" ;;
				16) echo "q" ;; 17) echo "w" ;; 18) echo "e" ;; 19) echo "r" ;;
				20) echo "t" ;; 21) echo "y" ;; 22) echo "u" ;; 23) echo "i" ;;
				24) echo "o" ;; 25) echo "p" ;;
				26) echo "leftbrace" ;; 27) echo "rightbrace" ;; 28) echo "enter" ;;
				29) echo "leftctrl" ;;
				30) echo "a" ;; 31) echo "s" ;; 32) echo "d" ;; 33) echo "f" ;;
				34) echo "g" ;; 35) echo "h" ;; 36) echo "j" ;; 37) echo "k" ;;
				38) echo "l" ;;
				39) echo "semicolon" ;; 40) echo "apostrophe" ;; 41) echo "grave" ;;
				42) echo "leftshift" ;; 43) echo "backslash" ;;
				44) echo "z" ;; 45) echo "x" ;; 46) echo "c" ;; 47) echo "v" ;;
				48) echo "b" ;; 49) echo "n" ;; 50) echo "m" ;;
				51) echo "comma" ;; 52) echo "dot" ;; 53) echo "slash" ;;
				54) echo "rightshift" ;;
				55) echo "kpasterisk" ;; 56) echo "leftalt" ;; 57) echo "space" ;;
				58) echo "capslock" ;;
				59) echo "f1" ;; 60) echo "f2" ;; 61) echo "f3" ;; 62) echo "f4" ;;
				63) echo "f5" ;; 64) echo "f6" ;; 65) echo "f7" ;; 66) echo "f8" ;;
				67) echo "f9" ;; 68) echo "f10" ;; 69) echo "numlock" ;; 70) echo "scrolllock" ;;
				71) echo "kp7" ;; 72) echo "kp8" ;; 73) echo "kp9" ;; 74) echo "kpminus" ;;
				75) echo "kp4" ;; 76) echo "kp5" ;; 77) echo "kp6" ;; 78) echo "kpplus" ;;
				79) echo "kp1" ;; 80) echo "kp2" ;; 81) echo "kp3" ;; 82) echo "kp0" ;;
				83) echo "kpdot" ;;
				87) echo "f11" ;; 88) echo "f12" ;;
				96) echo "kpenter" ;; 97) echo "rightctrl" ;; 98) echo "kpslash" ;;
				99) echo "sysrq" ;;
				100) echo "rightalt" ;;
				102) echo "home" ;; 103) echo "up" ;; 104) echo "pageup" ;;
				105) echo "left" ;; 106) echo "right" ;; 107) echo "end" ;;
				108) echo "down" ;; 109) echo "pagedown" ;; 110) echo "insert" ;;
				111) echo "delete" ;;
				119) echo "pause" ;;
				125) echo "leftmeta" ;; 126) echo "rightmeta" ;; 127) echo "compose" ;;
				*) echo "key_$_code" ;;
		esac
}

# --- THERMAL ---

device::read::thermal::zones() {
		local _dir _type _temp
		for _dir in /sys/class/thermal/thermal_zone*; do
				[[ -d "$_dir" ]] || continue
				_type=$(cat "$_dir/type" 2>/dev/null) || _type="unknown"
				_temp=$(cat "$_dir/temp" 2>/dev/null) || _temp="unknown"
				[[ "$_temp" != "unknown" ]] && _temp=$((_temp / 1000))
				printf '%s: %s°C\n' "$_type" "$_temp"
		done
}

device::read::thermal::temp() {
		local _zone="$1"
		local _temp
		_temp=$(cat "/sys/class/thermal/${_zone}/temp" 2>/dev/null) || { echo "unknown"; return 1; }
		echo $((_temp / 1000))
}

device::list::thermal() {
		local _dir
		for _dir in /sys/class/thermal/thermal_zone*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}

device::list::thermal::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/thermal/thermal_zone*; do
				[[ -d "$_dir" ]] || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}

# --- POWER SUPPLY ---

device::read::power::status() {
		local _bat="$1"
		cat "/sys/class/power_supply/${_bat}/status" 2>/dev/null || echo "unknown"
}

device::read::power::capacity() {
		local _bat="$1"
		cat "/sys/class/power_supply/${_bat}/capacity" 2>/dev/null || echo "unknown"
}

device::list::power() {
		local _dir
		for _dir in /sys/class/power_supply/*/type; do
				[[ -f "$_dir" ]] || continue
				basename "$(dirname "$_dir")"
		done
}

device::list::power::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/power_supply/*/type; do
				[[ -f "$_dir" ]] || continue
				_out+=("$(basename "$(dirname "$_dir")")")
		done
		_ref=("${_out[@]}")
}

# --- LEDs ---

device::read::led::brightness() {
		local _led="$1"
		cat "/sys/class/leds/${_led}/brightness" 2>/dev/null || echo "unknown"
}

device::read::led::max_brightness() {
		local _led="$1"
		cat "/sys/class/leds/${_led}/max_brightness" 2>/dev/null || echo "unknown"
}

device::list::led() {
		local _dir
		for _dir in /sys/class/leds/*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}

device::list::led::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/leds/*; do
				[[ -d "$_dir" ]] || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}

# --- HWMON ---

device::read::hwmon::temp() {
		local _hwmon="${1:-hwmon0}"
		local _temp
		_temp=$(cat "/sys/class/hwmon/${_hwmon}/temp1_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo $((_temp / 1000))
}

device::read::hwmon::fan() {
		local _hwmon="${1:-hwmon0}"
		local _fan
		_fan=$(cat "/sys/class/hwmon/${_hwmon}/fan1_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "$_fan"
}

device::read::hwmon::voltage() {
		local _hwmon="${1:-hwmon0}"
		local _volt
		_volt=$(cat "/sys/class/hwmon/${_hwmon}/in0_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "$_volt"
}

device::list::hwmon() {
		local _dir _name
		for _dir in /sys/class/hwmon/hwmon*; do
				[[ -d "$_dir" ]] || continue
				_name=$(cat "$_dir/name" 2>/dev/null) || _name="unknown"
				printf '%s (%s)\n' "$(basename "$_dir")" "$_name"
		done
}

device::list::hwmon::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir _name
		for _dir in /sys/class/hwmon/hwmon*; do
				[[ -d "$_dir" ]] || continue
				_name=$(cat "$_dir/name" 2>/dev/null) || _name="unknown"
				_out+=("$(basename "$_dir") (${_name})")
		done
		_ref=("${_out[@]}")
}

# --- SERIAL PORTS ---

device::read::serial::ports() {
		local _dir _driver
		for _dir in /sys/class/tty/ttyS* /sys/class/tty/ttyUSB* /sys/class/tty/ttyACM*; do
				[[ -d "$_dir" ]] || continue
				_driver=$(readlink "$_dir/device/driver" 2>/dev/null | xargs basename 2>/dev/null) || _driver="unknown"
				printf '%s driver=%s\n' "$(basename "$_dir")" "$_driver"
		done
}

device::read::serial::info() {
		local _port="$1"
		local _dir="/sys/class/tty/${_port}"
		[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
		local _driver _type
		_driver=$(readlink "$_dir/device/driver" 2>/dev/null | xargs basename 2>/dev/null) || _driver="unknown"
		if [[ -e "/dev/${_port}" ]]; then
				if [[ -c "/dev/${_port}" ]]; then
						_type="char"
				else
						_type="unknown"
				fi
		else
				_type="missing"
		fi
		printf 'port=%s driver=%s type=%s\n' "$_port" "$_driver" "$_type"
}

device::list::serial() {
		local _dir
		for _dir in /sys/class/tty/ttyS* /sys/class/tty/ttyUSB* /sys/class/tty/ttyACM*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}

device::list::serial::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/tty/ttyS* /sys/class/tty/ttyUSB* /sys/class/tty/ttyACM*; do
				[[ -d "$_dir" ]] || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}

