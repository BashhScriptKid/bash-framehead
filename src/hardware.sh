#!/usr/bin/env bash
# hardware.sh — bash-frameheader hardware lib
# Requires: runtime.sh (runtime::os, runtime::has_command)

# --- CPU ---

hardware::cpu::name() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				local cpu
				case "$(uname -m)" in
						"frv"|"hppa"|"m68k"|"openrisc"|"or"*|"powerpc"|"ppc"*|"sparc"*)
								cpu="$(awk -F':' '/^cpu\t|^CPU/ {printf $2; exit}' /proc/cpuinfo)"
								;;
						"s390"*)
								cpu="$(awk -F'=' '/machine/ {print $4; exit}' /proc/cpuinfo)"
								;;
						"ia64"|"m32r")
								cpu="$(awk -F':' '/model/ {print $2; exit}' /proc/cpuinfo)"
								[[ -z "$cpu" ]] && cpu="$(awk -F':' '/family/ {printf $2; exit}' /proc/cpuinfo)"
								;;
						*)
								cpu="$(awk -F'\\s*: | @' \
										'/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ {
												cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' /proc/cpuinfo)"
								;;
				esac
				cpu="${cpu//(TM)}"; cpu="${cpu//(tm)}"
				cpu="${cpu//(R)}";  cpu="${cpu//(r)}"
				cpu="${cpu//CPU}";  cpu="${cpu//Processor}"
				cpu="${cpu//Dual-Core}"; cpu="${cpu//Quad-Core}"
				cpu="${cpu//Six-Core}";  cpu="${cpu//Eight-Core}"
				cpu="${cpu//[1-9][0-9]-Core}"; cpu="${cpu//[0-9]-Core}"
				cpu="${cpu//Core2/Core 2}"
				echo "${cpu}" | xargs
				;;
		darwin)
				sysctl -n machdep.cpu.brand_string
				;;
		freebsd|openbsd|netbsd)
				sysctl -n hw.model 2>/dev/null | sed 's/[0-9]\..*//' | sed 's/ @.*//' | xargs
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::cpu::core_count::physical() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				case "$(uname -m)" in
						"sparc"*)
								lscpu 2>/dev/null | awk -F': *' '
										/^Core\(s\) per socket/ { cores=$2 }
										/^Socket\(s\)/          { sockets=$2 }
										END { print cores * sockets }'
								;;
						*)
								awk '/^core id/&&!a[$0]++{++i} END {print i}' /proc/cpuinfo
								;;
				esac
				;;
		darwin)
				sysctl -n hw.physicalcpu
				;;
		freebsd|openbsd|netbsd)
				sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::cpu::core_count::logical() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				case "$(uname -m)" in
						"sparc"*)
								lscpu 2>/dev/null | awk -F': *' '/^CPU\(s\)/ {print $2}'
								;;
						*)
								grep -c '^processor' /proc/cpuinfo
								;;
				esac
				;;
		darwin)
				sysctl -n hw.logicalcpu
				;;
		freebsd|openbsd|netbsd)
				sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::cpu::core_count::total() {
		hardware::cpu::core_count::logical
}

hardware::cpu::thread_count() {
		hardware::cpu::core_count::logical
}

hardware::cpu::frequencyMHz() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				local speed_dir="/sys/devices/system/cpu/cpu0/cpufreq"
				# /sys/ only exists on Linux/WSL — cygwin/mingw fall through to /proc/cpuinfo
				if [[ -d "$speed_dir" ]]; then
						local speed
						speed="$(cat "${speed_dir}/scaling_cur_freq" 2>/dev/null)" ||
						speed="$(cat "${speed_dir}/bios_limit" 2>/dev/null)" ||
						speed="$(cat "${speed_dir}/scaling_max_freq" 2>/dev/null)" ||
						speed="$(cat "${speed_dir}/cpuinfo_max_freq" 2>/dev/null)"
						echo "$((speed / 1000))"
				else
						case "$(uname -m)" in
								"sparc"*)
										echo "$(( $(cat /sys/devices/system/cpu/cpu0/clock_tick 2>/dev/null) / 1000000 ))"
										;;
								*)
										awk -F': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' /proc/cpuinfo \
												| sed 's/MHz//' | xargs
										;;
						esac
				fi
				;;
		darwin)
				sysctl -n hw.cpufrequency 2>/dev/null \
						| awk '{ printf "%d\n", $1/1000000 }' || echo "unknown"
				;;
		freebsd|openbsd|netbsd)
				sysctl -n hw.cpuspeed 2>/dev/null \
						|| sysctl -n hw.clockrate 2>/dev/null \
						|| echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::cpu::temp() {
		case "$(runtime::os)" in
		linux|wsl)
				local temp_dir
				for dir in /sys/class/hwmon/*; do
						[[ -f "${dir}/name" ]] || continue
						if [[ "$(< "${dir}/name")" =~ (cpu_thermal|coretemp|fam15h_power|k10temp) ]]; then
								local inputs=("${dir}"/temp*_input)
								temp_dir="${inputs[0]}"
								break
						fi
				done
				if [[ -f "$temp_dir" ]]; then
						awk '{ printf "%.1f\n", $1/1000 }' "$temp_dir"
				else
						echo "unknown"
				fi
				;;
		darwin)
				# No native CLI — would need osx-cpu-temp or similar
				echo "unknown"
				;;
		freebsd|dragonfly)
				sysctl -n dev.cpu.0.temperature 2>/dev/null | tr -d 'C' || echo "unknown"
				;;
		openbsd|netbsd)
				sysctl hw.sensors 2>/dev/null | \
						awk -F'=|degC' '/(ksmn|adt|lm|cpu)0.temp0/ {printf("%.1f\n", $2); exit}' \
						|| echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

# --- GPU ---

hardware::gpu() {
		case "$(runtime::os)" in
				linux|wsl|cygwin|mingw)
						if runtime::has_command nvidia-smi; then
								nvidia-smi -q 2>/dev/null | awk -F': ' '/Product Name/ { print $2; exit }' | xargs
						elif runtime::has_command lspci; then
								lspci -mm 2>/dev/null | awk -F'"' \
										'/VGA|3D|Display/ { print $6 }' | head -1 | xargs
						elif runtime::has_command glxinfo; then
								glxinfo 2>/dev/null | awk -F': ' \
										'/OpenGL renderer string/ { print $2 }' | head -1 | xargs
						else
								echo "unknown"
						fi
						;;
		darwin)
				system_profiler SPDisplaysDataType 2>/dev/null \
						| awk -F': ' '/Chipset Model/ { printf $2", " }' \
						| sed 's/, $//' | xargs
				;;
		freebsd|dragonfly)
				pciconf -lv 2>/dev/null \
						| grep -A4 'VGA' \
						| awk -F'=' '/device/ { gsub(/"/, "", $2); print $2 }' \
						| head -1 | xargs
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::gpu::vramMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				if runtime::has_command nvidia-smi; then
						nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1
				elif runtime::has_command lspci; then
						lspci -v 2>/dev/null \
								| grep -A12 'VGA' \
								| grep 'prefetchable' \
								| grep -oE '[0-9]+M' | head -1 | tr -d 'M'
				else
						echo "unknown"
				fi
				;;
		darwin)
				system_profiler SPDisplaysDataType 2>/dev/null \
						| awk '/VRAM/ { gsub(/[^0-9]/,"",$NF); print $NF }' | head -1 \
						|| echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

# --- RAM ---

hardware::ram::totalSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				awk '/MemTotal/ { printf "%d\n", $2/1024 }' /proc/meminfo
				;;
		darwin)
				sysctl -n hw.memsize | awk '{ printf "%d\n", $1/1024/1024 }'
				;;
		freebsd|dragonfly)
				sysctl -n hw.physmem 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
				;;
		netbsd)
				sysctl -n hw.physmem64 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
				;;
		openbsd)
				sysctl -n hw.physmem 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::ram::usedSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				# MemUsed = MemTotal + Shmem - MemFree - Buffers - Cached - SReclaimable
				# Uses MemAvailable when present (Linux 3.14+) for better accuracy
				awk '
						/MemTotal/     { total=$2 }
						/Shmem/        { shmem=$2 }
						/MemFree/      { free=$2 }
						/Buffers/      { buffers=$2 }
						/^Cached/      { cached=$2 }
						/SReclaimable/ { sreclaimable=$2 }
						/MemAvailable/ { avail=$2 }
						END {
								if (avail) {
										printf "%d\n", (total - avail) / 1024
								} else {
										printf "%d\n", (total + shmem - free - buffers - cached - sreclaimable) / 1024
								}
						}' /proc/meminfo
				;;
		darwin)
				local hw_pagesize pages_app pages_wired pages_compressed
				hw_pagesize="$(sysctl -n hw.pagesize)"
				pages_app=$(( $(sysctl -n vm.page_pageable_internal_count) - $(sysctl -n vm.page_purgeable_count) ))
				pages_wired="$(vm_stat | awk '/ wired/ { gsub(/\./, "", $4); print $4 }')"
				pages_compressed="$(vm_stat | awk '/ occupied/ { gsub(/\./, "", $5); print $5 }')"
				pages_compressed="${pages_compressed:-0}"
				echo "$(( (pages_app + pages_wired + pages_compressed) * hw_pagesize / 1024 / 1024 ))"
				;;
		freebsd|dragonfly)
				local hw_pagesize mem_inactive mem_unused mem_cache mem_free mem_total
				hw_pagesize="$(sysctl -n hw.pagesize)"
				mem_inactive=$(( $(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize ))
				mem_unused=$(( $(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize ))
				mem_cache=$(( $(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize ))
				mem_free=$(( (mem_inactive + mem_unused + mem_cache) / 1024 / 1024 ))
				mem_total=$(hardware::ram::totalSpaceMB)
				echo $(( mem_total - mem_free ))
				;;
		openbsd)
				vmstat | awk 'END { printf $3 }' | tr -d 'M'
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::ram::freeSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				awk '/MemAvailable/ { printf "%d\n", $2/1024 }' /proc/meminfo
				;;
		darwin)
				local hw_pagesize pages_free
				hw_pagesize="$(sysctl -n hw.pagesize)"
				pages_free="$(vm_stat | awk '/Pages free/ { gsub(/\./, "", $3); print $3 }')"
				echo $(( pages_free * hw_pagesize / 1024 / 1024 ))
				;;
		freebsd|dragonfly|openbsd|netbsd)
				local total used
				total=$(hardware::ram::totalSpaceMB)
				used=$(hardware::ram::usedSpaceMB)
				echo $(( total - used ))
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::ram::percentage() {
		local used total
		used=$(hardware::ram::usedSpaceMB)
		total=$(hardware::ram::totalSpaceMB)
		[[ "$used" == "unknown" || "$total" == "unknown" ]] && echo "unknown" && return
		awk "BEGIN { printf \"%.1f\n\", ($used / $total) * 100 }"
}

# --- DISK ---

hardware::disk::devices() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -dno NAME 2>/dev/null | grep -v '^loop' | tr '\n' ' ' | xargs
				;;
		darwin)
				diskutil list 2>/dev/null | awk '/^\/dev\/disk/ { print $1 }' | tr '\n' ' ' | xargs
				;;
		freebsd|dragonfly|openbsd|netbsd)
				sysctl -n kern.disks 2>/dev/null | tr ' ' '\n' | grep -v '^$' | tr '\n' ' ' | xargs
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::disk::count::total() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -dno NAME 2>/dev/null | grep -cv '^loop' | xargs
				;;
		darwin)
				diskutil list 2>/dev/null | grep -c '^/dev/disk'
				;;
		*)
				hardware::disk::devices | wc -w | xargs
				;;
		esac
}

hardware::disk::count::physical() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -dno NAME,TYPE 2>/dev/null | awk '/disk/ && !/loop/' | wc -l | xargs
				;;
		darwin)
				diskutil list physical 2>/dev/null | grep -c '^/dev/disk'
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::disk::count::virtual() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -dno NAME,TYPE 2>/dev/null | grep -c 'loop\|ram'
				;;
		darwin)
				diskutil list 2>/dev/null | grep -c 'virtual'
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::disk::name() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -dno MODEL 2>/dev/null | grep -v '^$' | head -1 | xargs
				;;
		darwin)
				diskutil info disk0 2>/dev/null \
						| awk -F': +' '/Device \/ Media Name/ { print $2 }' | xargs
				;;
		*)
				echo "unknown"
				;;
		esac
}

# PARTITIONS
# df flags vary per OS/version — detect them like neofetch does

_hardware::df_flags() {
		local df_version
		df_version=$(df --version 2>&1)
		case "$df_version" in
				*IMitv*)   echo "-P -g" ;;  # AIX
				*befhikm*) echo "-P -k" ;;  # IRIX
				*hiklnP*)  echo "-h"    ;;  # OpenBSD
				*)         echo "-P -h" ;;  # Linux, macOS, Cygwin, MinGW, etc.
		esac
}

hardware::partition::count() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -no NAME 2>/dev/null | grep -cv '^loop' | xargs
				;;
		darwin)
				diskutil list 2>/dev/null | grep -c '^\s*[0-9]'
				;;
		*)
				echo "unknown"
				;;
		esac
}

# Returns human-readable disk info for a mount point (default: /)
# Usage: hardware::partition::info [mountpoint]
hardware::partition::info() {
		local mount="${1:-/}"
		runtime::has_command df || { echo "unknown"; return 1; }

		local -a flags
		read -ra flags <<< "$(_hardware::df_flags)"

		local -a disks
		IFS=$'\n' read -d "" -ra disks <<< "$(df "${flags[@]}" "$mount" 2>/dev/null)"
		unset "disks[0]"

		[[ ${disks[*]} ]] || { echo "unknown"; return 1; }

		local -a disk_info
		IFS=" " read -ra disk_info <<< "${disks[0]}"
		local used="${disk_info[${#disk_info[@]} - 4]}"
		local total="${disk_info[${#disk_info[@]} - 5]}"
		local perc="${disk_info[${#disk_info[@]} - 2]/\%}"
		echo "${used} / ${total} (${perc}%)"
}

hardware::partition::totalSpaceMB() {
		local device="${1:-/}"
		df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$2); print $2 }'
}

hardware::partition::usedSpaceMB() {
		local device="${1:-/}"
		df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$3); print $3 }'
}

hardware::partition::freeSpaceMB() {
		local device="${1:-/}"
		df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$4); print $4 }'
}

hardware::partition::usagePercent() {
		local device="${1:-/}"
		df "$device" 2>/dev/null | awk 'NR==2 { gsub(/%/,"",$5); print $5 }'
}

# --- SWAP ---

hardware::swap::totalSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				awk '/SwapTotal/ { printf "%d\n", $2/1024 }' /proc/meminfo
				;;
		darwin)
				sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$3); print $3 }'
				;;
		freebsd|dragonfly)
				swapinfo -k 2>/dev/null | awk 'NR>1 { total+=$2 } END { printf "%d\n", total/1024 }'
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::swap::usedSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				awk '/SwapTotal/ { total=$2 } /SwapFree/ { free=$2 }
						 END { printf "%d\n", (total-free)/1024 }' /proc/meminfo
				;;
		darwin)
				sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$6); print $6 }'
				;;
		freebsd|dragonfly)
				swapinfo -k 2>/dev/null | awk 'NR>1 { used+=$3 } END { printf "%d\n", used/1024 }'
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::swap::freeSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				awk '/SwapFree/ { printf "%d\n", $2/1024 }' /proc/meminfo
				;;
		darwin)
				sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$9); print $9 }'
				;;
		freebsd|dragonfly)
				local total used
				total=$(hardware::swap::totalSpaceMB)
				used=$(hardware::swap::usedSpaceMB)
				echo $(( total - used ))
				;;
		*)
				echo "unknown"
				;;
		esac
}

# BATTERY
# Uses dynamic discovery of BAT*, axp288_fuel_gauge, CMB* (tablets/embedded)

_hardware::battery::find_bat() {
		# neofetch covers BAT*, axp288_fuel_gauge, and CMB* (embedded/tablet devices)
		for bat in "/sys/class/power_supply/"{BAT,axp288_fuel_gauge,CMB}*; do
				[[ -f "${bat}/capacity" ]] && echo "$bat" && return
		done
}

hardware::battery::present() {
		case "$(runtime::os)" in
		linux|wsl)
				[[ -n "$(_hardware::battery::find_bat)" ]]
				;;
		darwin)
				system_profiler SPPowerDataType 2>/dev/null | grep -q 'Battery'
				;;
		freebsd|dragonfly)
				sysctl -n hw.acpi.battery.life 2>/dev/null | grep -qv '^$'
				;;
		cygwin|mingw)
				wmic Path Win32_Battery get EstimatedChargeRemaining 2>/dev/null \
						| grep -qv '^EstimatedChargeRemaining'
				;;
		*)
				return 1
				;;
		esac
}

hardware::battery::percentage() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				cat "${bat}/capacity" 2>/dev/null || echo "unknown"
				;;
		darwin)
				pmset -g batt 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1 || echo "unknown"
				;;
		freebsd|dragonfly)
				acpiconf -i 0 2>/dev/null \
						| awk -F ':\t' '/Remaining capacity/ {print $2}' \
						| tr -d '%' || echo "unknown"
				;;
		netbsd)
				envstat 2>/dev/null | awk '/charge:/ {print $2}' | cut -d. -f1 || echo "unknown"
				;;
		openbsd)
				local full now
				full="$(sysctl -n hw.sensors.acpibat0.watthour0 hw.sensors.acpibat0.amphour0 2>/dev/null)"
				full="${full%% *}"
				now="$(sysctl -n hw.sensors.acpibat0.watthour3 hw.sensors.acpibat0.amphour3 2>/dev/null)"
				now="${now%% *}"
				[[ -z "$full" || -z "$now" ]] && echo "unknown" && return
				echo "$(( 100 * ${now/\.} / ${full/\.} ))"
				;;
		cygwin|mingw)
				local val
				val="$(wmic Path Win32_Battery get EstimatedChargeRemaining 2>/dev/null \
						| grep -v 'EstimatedChargeRemaining' | tr -d '[:space:]')"
				[[ -n "$val" ]] && echo "$val" || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::battery::is_charging() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && return 1
				[[ "$(cat "${bat}/status" 2>/dev/null)" == "Charging" ]]
				;;
		darwin)
				pmset -g batt 2>/dev/null | grep -q 'AC Power'
				;;
		freebsd|dragonfly)
				sysctl -n hw.acpi.acline 2>/dev/null | grep -q '^1$'
				;;
		openbsd)
				local state
				state="$(sysctl -n hw.sensors.acpibat0.raw0 2>/dev/null)"
				state="${state##? (battery }"
				state="${state%)*}"
				[[ "$state" == "charging" ]]
				;;
		cygwin|mingw)
				local state
				state="$(wmic /NameSpace:'\\root\WMI' Path BatteryStatus get Charging 2>/dev/null)"
				[[ "$state" == *TRUE* ]]
				;;
		*)
				return 1
				;;
		esac
}

hardware::battery::status() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				cat "${bat}/status" 2>/dev/null || echo "unknown"
				;;
		darwin)
				local state
				state="$(pmset -g batt 2>/dev/null | awk '/;/ {print $4}')"
				[[ "$state" == "charging;" ]] && echo "Charging" || echo "Discharging"
				;;
		freebsd|dragonfly)
				local acline state
				acline=$(sysctl -n hw.acpi.acline 2>/dev/null)
				state=$(sysctl -n hw.acpi.battery.state 2>/dev/null)
				if [[ "$acline" == "1" && "$state" == "0" ]]; then echo "Full"
				elif [[ "$acline" == "1" ]]; then echo "Charging"
				else echo "Discharging"
				fi
				;;
		openbsd)
				local state
				state="$(sysctl -n hw.sensors.acpibat0.raw0 2>/dev/null)"
				state="${state##? (battery }"
				state="${state%)*}"
				echo "${state^}"  # capitalise first letter
				;;
		cygwin|mingw)
				hardware::battery::is_charging && echo "Charging" || echo "Discharging"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::battery::time_remaining() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				if runtime::has_command upower; then
						upower -i "$(upower -e 2>/dev/null | grep battery | head -1)" 2>/dev/null \
								| awk '/time to empty/ { print $4, $5 }' || echo "unknown"
				else
						cat "${bat}/time_to_empty_now" 2>/dev/null || echo "unknown"
				fi
				;;
		darwin)
				pmset -g batt 2>/dev/null | grep -oE '[0-9]+:[0-9]+ remaining' | head -1 || echo "unknown"
				;;
		freebsd|dragonfly)
				sysctl -n hw.acpi.battery.time 2>/dev/null || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::battery::capacity() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				cat "${bat}/charge_full_design" 2>/dev/null \
						|| cat "${bat}/energy_full_design" 2>/dev/null \
						|| echo "unknown"
				;;
		darwin)
				system_profiler SPPowerDataType 2>/dev/null \
						| awk -F': ' '/Full Charge Capacity/ { print $2 }' || echo "unknown"
				;;
		freebsd|dragonfly)
				sysctl -n hw.acpi.battery.capacity 2>/dev/null || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

hardware::battery::health() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat full design
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				full=$(cat "${bat}/charge_full" 2>/dev/null || cat "${bat}/energy_full" 2>/dev/null)
				design=$(cat "${bat}/charge_full_design" 2>/dev/null || cat "${bat}/energy_full_design" 2>/dev/null)
				[[ -z "$full" || -z "$design" ]] && echo "unknown" && return
				awk "BEGIN { printf \"%.1f\n\", ($full / $design) * 100 }"
				;;
		darwin)
				system_profiler SPPowerDataType 2>/dev/null \
						| awk -F': ' '/Condition/ { print $2 }' || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}

