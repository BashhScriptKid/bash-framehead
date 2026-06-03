#!/usr/bin/env bash
# kernel.sh — kernel introspection and control
# Requires: runtime.sh (runtime::has_command, runtime::is_root, runtime::os)
#
# Platform support:
#   Linux:  full support (~170 functions)
#   BSD:    dedicated APIs via kernel::bsd::* (~55 functions) + cross-platform
#   macOS:  dedicated APIs via kernel::xnu::* (~55 functions) + cross-platform
#   Other:  basic uname-based functions only

# --- IDENTITY ---

kernel::version() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		if [[ -f /proc/version ]]; then
			local _ver
			_ver=$(uname -r)
			printf '%s' "${_ver%%-*}"
		else
			uname -r
		fi
		;;
	darwin)
		uname -r
		;;
	*)
		return 1
		;;
	esac
}

# --- MEMORY MANAGEMENT ---

kernel::mm::ksm::status() {
	local _run _shared _sharing _profit
	_run=$(cat /sys/kernel/mm/ksm/run 2>/dev/null) || { echo "unknown"; return 1; }
	_shared=$(cat /sys/kernel/mm/ksm/pages_shared 2>/dev/null)
	_sharing=$(cat /sys/kernel/mm/ksm/pages_sharing 2>/dev/null)
	_profit=$(cat /sys/kernel/mm/ksm/general_profit 2>/dev/null)
	printf 'run=%s shared=%s sharing=%s profit=%s\n' \
		"$_run" "${_shared:-0}" "${_sharing:-0}" "${_profit:-0}"
}

kernel::mm::ksm::profit() {
	local _bytes
	_bytes=$(cat /sys/kernel/mm/ksm/general_profit 2>/dev/null) || { echo "0"; return 1; }
	if (( _bytes >= 1073741824 )); then
		printf '%.1fGB' "$((_bytes / 1073741824))"
	elif (( _bytes >= 1048576 )); then
		printf '%.1fMB' "$((_bytes / 1048576))"
	elif (( _bytes >= 1024 )); then
		printf '%.1fKB' "$((_bytes / 1024))"
	else
		echo "${_bytes}B"
	fi
}

kernel::mm::ksm::run::get() {
	cat /sys/kernel/mm/ksm/run 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::run::set() {
	runtime::is_root || { echo "kernel::mm::ksm::run::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/run
}

kernel::mm::ksm::pages_to_scan::get() {
	cat /sys/kernel/mm/ksm/pages_to_scan 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::pages_to_scan::set() {
	runtime::is_root || { echo "kernel::mm::ksm::pages_to_scan::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/pages_to_scan
}

kernel::mm::ksm::sleep_ms::get() {
	cat /sys/kernel/mm/ksm/sleep_millisecs 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::sleep_ms::set() {
	runtime::is_root || { echo "kernel::mm::ksm::sleep_ms::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/sleep_millisecs
}

kernel::mm::ksm::max_page_sharing::get() {
	cat /sys/kernel/mm/ksm/max_page_sharing 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::max_page_sharing::set() {
	runtime::is_root || { echo "kernel::mm::ksm::max_page_sharing::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/max_page_sharing
}

kernel::mm::ksm::merge_across_nodes::get() {
	cat /sys/kernel/mm/ksm/merge_across_nodes 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::merge_across_nodes::set() {
	runtime::is_root || { echo "kernel::mm::ksm::merge_across_nodes::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/merge_across_nodes
}

kernel::mm::ksm::use_zero_pages::get() {
	cat /sys/kernel/mm/ksm/use_zero_pages 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::use_zero_pages::set() {
	runtime::is_root || { echo "kernel::mm::ksm::use_zero_pages::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/use_zero_pages
}

kernel::mm::ksm::advisor_mode::get() {
	cat /sys/kernel/mm/ksm/advisor_mode 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::advisor_mode::set() {
	runtime::is_root || { echo "kernel::mm::ksm::advisor_mode::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/advisor_mode
}

kernel::mm::ksm::advisor_max_cpu::get() {
	cat /sys/kernel/mm/ksm/advisor_max_cpu 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::advisor_max_cpu::set() {
	runtime::is_root || { echo "kernel::mm::ksm::advisor_max_cpu::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/advisor_max_cpu
}

kernel::mm::ksm::advisor_max_pages::get() {
	cat /sys/kernel/mm/ksm/advisor_max_pages_to_scan 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::advisor_max_pages::set() {
	runtime::is_root || { echo "kernel::mm::ksm::advisor_max_pages::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/advisor_max_pages_to_scan
}

kernel::mm::ksm::advisor_min_pages::get() {
	cat /sys/kernel/mm/ksm/advisor_min_pages_to_scan 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::advisor_min_pages::set() {
	runtime::is_root || { echo "kernel::mm::ksm::advisor_min_pages::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/advisor_min_pages_to_scan
}

kernel::mm::ksm::advisor_scan_time::get() {
	cat /sys/kernel/mm/ksm/advisor_target_scan_time 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::advisor_scan_time::set() {
	runtime::is_root || { echo "kernel::mm::ksm::advisor_scan_time::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/advisor_target_scan_time
}

kernel::mm::ksm::chain_prune_ms::get() {
	cat /sys/kernel/mm/ksm/stable_node_chains_prune_millisecs 2>/dev/null || echo "unknown"
}

kernel::mm::ksm::chain_prune_ms::set() {
	runtime::is_root || { echo "kernel::mm::ksm::chain_prune_ms::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/ksm/stable_node_chains_prune_millisecs
}

kernel::mm::thp::status() {
	local _enabled _defrag _collapse _scan
	_enabled=$(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null) || { echo "unknown"; return 1; }
	_defrag=$(cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null)
	_collapse=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed 2>/dev/null)
	_scan=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/full_scans 2>/dev/null)
	printf 'enabled=%s defrag=%s collapsed=%s scans=%s\n' \
		"$_enabled" "${_defrag:-unknown}" "${_collapse:-0}" "${_scan:-0}"
}

kernel::mm::thp::collapse_rate() {
	local _collapsed _scans
	_collapsed=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed 2>/dev/null) || { echo "0"; return 1; }
	_scans=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/full_scans 2>/dev/null) || { echo "0"; return 1; }
	(( _scans > 0 )) && echo $((_collapsed / _scans)) || echo "0"
}

kernel::mm::thp::enabled::get() {
	cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || echo "unknown"
}

kernel::mm::thp::enabled::set() {
	runtime::is_root || { echo "kernel::mm::thp::enabled::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/enabled
}

kernel::mm::thp::defrag::get() {
	cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || echo "unknown"
}

kernel::mm::thp::defrag::set() {
	runtime::is_root || { echo "kernel::mm::thp::defrag::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/defrag
}

kernel::mm::thp::shmem_enabled::get() {
	cat /sys/kernel/mm/transparent_hugepage/shmem_enabled 2>/dev/null || echo "unknown"
}

kernel::mm::thp::shmem_enabled::set() {
	runtime::is_root || { echo "kernel::mm::thp::shmem_enabled::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/shmem_enabled
}

kernel::mm::thp::use_zero_page::get() {
	cat /sys/kernel/mm/transparent_hugepage/use_zero_page 2>/dev/null || echo "unknown"
}

kernel::mm::thp::use_zero_page::set() {
	runtime::is_root || { echo "kernel::mm::thp::use_zero_page::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/use_zero_page
}

kernel::mm::thp::shrink_underused::get() {
	cat /sys/kernel/mm/transparent_hugepage/shrink_underused 2>/dev/null || echo "unknown"
}

kernel::mm::thp::shrink_underused::set() {
	runtime::is_root || { echo "kernel::mm::thp::shrink_underused::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/shrink_underused
}

kernel::mm::thp::khugepaged::pages_to_scan::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::pages_to_scan::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::pages_to_scan::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
}

kernel::mm::thp::khugepaged::scan_sleep_ms::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::scan_sleep_ms::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::scan_sleep_ms::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
}

kernel::mm::thp::khugepaged::alloc_sleep_ms::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::alloc_sleep_ms::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::alloc_sleep_ms::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
}

kernel::mm::thp::khugepaged::defrag::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::defrag::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::defrag::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
}

kernel::mm::thp::khugepaged::max_ptes_none::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::max_ptes_none::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::max_ptes_none::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
}

kernel::mm::thp::khugepaged::max_ptes_shared::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_shared 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::max_ptes_shared::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::max_ptes_shared::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_shared
}

kernel::mm::thp::khugepaged::max_ptes_swap::get() {
	cat /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap 2>/dev/null || echo "unknown"
}

kernel::mm::thp::khugepaged::max_ptes_swap::set() {
	runtime::is_root || { echo "kernel::mm::thp::khugepaged::max_ptes_swap::set: requires root" >&2; return 1; }
	echo "$1" > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
}

kernel::mm::hugepages::status() {
	local _dir _size _free _total
	for _dir in /sys/kernel/mm/hugepages/hugepages-*kB; do
		[[ -d "$_dir" ]] || continue
		_size=${_dir##*-}
		_size=${_size%kB}
		_total=$(cat "$_dir/nr_hugepages" 2>/dev/null) || continue
		_free=$(cat "$_dir/free_hugepages" 2>/dev/null) || _free=0
		printf '%skB: free=%s total=%s\n' "$_size" "$_free" "$_total"
	done
}

kernel::mm::hugepages::utilization() {
	local _dir _total _free _utilized=0 _total_all=0
	for _dir in /sys/kernel/mm/hugepages/hugepages-*kB; do
		[[ -d "$_dir" ]] || continue
		_total=$(cat "$_dir/nr_hugepages" 2>/dev/null) || continue
		_free=$(cat "$_dir/free_hugepages" 2>/dev/null) || _free=0
		_total_all=$((_total_all + _total))
		_utilized=$((_utilized + _total - _free))
	done
	(( _total_all > 0 )) && echo $((_utilized * 100 / _total_all)) || echo "0"
}

kernel::mm::hugepages::nr_hugepages::get() {
	cat /proc/sys/vm/nr_hugepages 2>/dev/null || echo "unknown"
}

kernel::mm::hugepages::nr_hugepages::set() {
	runtime::is_root || { echo "kernel::mm::hugepages::nr_hugepages::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/nr_hugepages
}

kernel::mm::hugepages::demote() {
	runtime::is_root || { echo "kernel::mm::hugepages::demote: requires root" >&2; return 1; }
	echo 1 > /sys/kernel/mm/hugepages/hugepages-2048kB/demote 2>/dev/null
}

kernel::mm::hugepages::overcommit::get() {
	cat /proc/sys/vm/nr_overcommit_hugepages 2>/dev/null || echo "unknown"
}

kernel::mm::hugepages::overcommit::set() {
	runtime::is_root || { echo "kernel::mm::hugepages::overcommit::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/nr_overcommit_hugepages
}

kernel::mm::lru_gen::status() {
	local _enabled _ttl
	_enabled=$(cat /sys/kernel/mm/lru_gen/enabled 2>/dev/null) || { echo "unknown"; return 1; }
	_ttl=$(cat /sys/kernel/mm/lru_gen/min_ttl_ms 2>/dev/null) || _ttl="unknown"
	printf 'enabled=%s ttl_ms=%s\n' "$_enabled" "$_ttl"
}

kernel::version::full() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		cat /proc/version 2>/dev/null || uname -v
		;;
	*)
		uname -v 2>/dev/null || echo "unknown"
		;;
	esac
}

kernel::version::major() {
	local _ver _major
	_ver=$(uname -r)
	_major="${_ver%%.*}"
	printf '%s' "${_major#-}"
}

kernel::version::minor() {
	local _ver _rest _minor
	_ver=$(uname -r)
	_rest="${_ver#*.}"
	_minor="${_rest%%.*}"
	printf '%s' "$_minor"
}

kernel::version::patch() {
	local _ver _rest
	_ver=$(uname -r)
	_rest="${_ver#*.}"
	printf '%s' "${_rest#*.}"
}

kernel::release() {
	uname -r 2>/dev/null || echo "unknown"
}

kernel::arch() {
	uname -m 2>/dev/null || echo "unknown"
}

kernel::name() {
	uname -s 2>/dev/null || echo "unknown"
}

kernel::hostname() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		cat /proc/sys/kernel/hostname 2>/dev/null || hostname
		;;
	darwin|freebsd|openbsd|netbsd)
		sysctl -n kern.hostname 2>/dev/null || hostname
		;;
	*)
		hostname 2>/dev/null || echo "unknown"
		;;
	esac
}

kernel::hostname::set() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		runtime::is_root || { echo "kernel::hostname::set: requires root" >&2; return 1; }
		echo "$1" > /proc/sys/kernel/hostname
		;;
	darwin)
		runtime::is_root || { echo "kernel::hostname::set: requires root" >&2; return 1; }
		scutil --set ComputerName "$1" 2>/dev/null || return 1
		;;
	freebsd|openbsd|netbsd)
		runtime::is_root || { echo "kernel::hostname::set: requires root" >&2; return 1; }
		sysctl kern.hostname="$1" 2>/dev/null || return 1
		;;
	*)
		hostname "$1" 2>/dev/null || return 1
		;;
	esac
}

# --- LOAD / UPTIME ---

kernel::load::avg() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{print $1, $2, $3}' /proc/loadavg 2>/dev/null
		;;
	darwin|freebsd|openbsd|netbsd)
		sysctl -n vm.loadavg 2>/dev/null | awk '{print $1, $2, $3}'
		;;
	*)
		uptime 2>/dev/null | awk -F'load average[s]?: ' '{print $2}'
		;;
	esac
}

kernel::load::is_heavy() {
	local _load _nproc _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		_load=$(awk '{print $1}' /proc/loadavg 2>/dev/null) || return 1
		_nproc=$(nproc 2>/dev/null) || _nproc=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || _nproc=1
		awk "BEGIN{exit !($_load > $_nproc)}" 2>/dev/null
		;;
	darwin|freebsd|openbsd|netbsd)
		_load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $1}') || return 1
		_nproc=$(sysctl -n hw.ncpu 2>/dev/null) || _nproc=1
		awk "BEGIN{exit !($_load > $_nproc)}" 2>/dev/null
		;;
	*)
		_load=$(uptime 2>/dev/null | awk -F'load average[s]?: ' '{print $2}' | awk -F, '{print $1}') || return 1
		_nproc=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || _nproc=1
		awk "BEGIN{exit !($_load > $_nproc)}" 2>/dev/null
		;;
	esac
}

kernel::load::running_tasks() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{print $4}' /proc/loadavg 2>/dev/null
		;;
	darwin|freebsd|openbsd|netbsd)
		sysctl -n vm.loadavg 2>/dev/null | awk '{print $4}'
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::uptime() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{printf "%.0f", $1}' /proc/uptime 2>/dev/null
		;;
	darwin)
		local _boot _now
		_boot=$(sysctl -n kern.boottime 2>/dev/null | awk '{print $4}' | tr -d ',')
		_now=$(date +%s)
		[[ -n "$_boot" && -n "$_now" ]] && echo $((_now - _boot))
		;;
	freebsd|openbsd|netbsd)
		local _boot _now
		_boot=$(sysctl -n kern.boottime 2>/dev/null | awk -F'[= ]+' '{for(i=1;i<=NF;i++)if($i~/^[0-9]+$/){print $i;exit}}')
		_now=$(date +%s)
		[[ -n "$_boot" && -n "$_now" ]] && echo $((_now - _boot))
		;;
	*)
		local _boot_ts _now_ts
		_boot_ts=$(uptime -s 2>/dev/null | xargs -I{} date -d {} +%s 2>/dev/null) || return 1
		_now_ts=$(date +%s)
		echo $((_now_ts - _boot_ts))
		;;
	esac
}

# --- MODULES ---

kernel::modules::list() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{printf "%s %s %s\n", $1, $2, $3}' /proc/modules 2>/dev/null
		;;
	darwin)
		kextstat 2>/dev/null | awk 'NR>1{printf "%s %s %s\n", $2, $3, $4}'
		;;
	freebsd|openbsd|netbsd)
		kldstat 2>/dev/null | awk 'NR>1{printf "%s %s %s\n", $2, $3, $4}'
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::modules::count() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		wc -l < /proc/modules 2>/dev/null
		;;
	darwin)
		kextstat 2>/dev/null | awk 'NR>1' | wc -l
		;;
	freebsd|openbsd|netbsd)
		kldstat 2>/dev/null | awk 'NR>1' | wc -l
		;;
	*)
		echo "0"
		;;
	esac
}

kernel::modules::is_loaded() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		grep -q "^${_module} " /proc/modules 2>/dev/null
		;;
	darwin)
		kextstat 2>/dev/null | grep -q "$_module"
		;;
	freebsd|openbsd|netbsd)
		kldstat 2>/dev/null | grep -q "$_module"
		;;
	*)
		return 1
		;;
	esac
}

# --- MEMORY INFO ---

kernel::meminfo::total() {
	local _os _bytes
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '/^MemTotal:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null
		;;
	darwin)
		_bytes=$(sysctl -n hw.memsize 2>/dev/null) && echo $((_bytes / 1024))
		;;
	freebsd|openbsd|netbsd)
		_bytes=$(sysctl -n hw.physmem 2>/dev/null) && echo $((_bytes / 1024))
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::meminfo::free() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '/^MemFree:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null
		;;
	darwin)
		local _pages _page_size
		_pages=$(vm_stat 2>/dev/null | awk '/Pages free/{gsub(/\./,"",$3); print $3}')
		_page_size=$(sysctl -n hw.pagesize 2>/dev/null) || _page_size=4096
		[[ -n "$_pages" ]] && echo $((_pages * _page_size / 1024))
		;;
	freebsd|openbsd|netbsd)
		vmstat -s 2>/dev/null | awk '/pages free/{printf "%.0f", $1/1024}' || echo "unknown"
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::meminfo::used() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '/^MemTotal:/{total=$2} /^MemFree:/{free=$2} /^Buffers:/{buf=$2} /^Cached:/{cached=$2} END{printf "%.0f", (total-free-buf-cached)/1024}' /proc/meminfo 2>/dev/null
		;;
	darwin)
		local _pages _page_size _total _free
		_pages=$(vm_stat 2>/dev/null | awk '/Pages active/{gsub(/\./,"",$3); print $3}')
		_page_size=$(sysctl -n hw.pagesize 2>/dev/null) || _page_size=4096
		[[ -n "$_pages" ]] && echo $((_pages * _page_size / 1024))
		;;
	freebsd|openbsd|netbsd)
		local _active _page_size
		_active=$(vmstat -s 2>/dev/null | awk '/pages active/{print $1}') || _active=0
		_page_size=$(sysctl -n hw.pagesize 2>/dev/null) || _page_size=4096
		echo $((_active * _page_size / 1024))
		;;
	*)
		echo "unknown"
		;;
	esac
}

# --- SECURITY ---

kernel::security::lockdown() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		if [[ -f /sys/kernel/security/lockdown ]]; then
			cat /sys/kernel/security/lockdown 2>/dev/null
		else
			echo "[none]"
		fi
		;;
	darwin)
		local _sip
		_sip=$(csrutil status 2>&1)
		if [[ "$_sip" == *"enabled"* ]]; then
			echo "sip=enabled"
		else
			echo "sip=disabled"
		fi
		;;
	freebsd|openbsd|netbsd)
		local _level
		_level=$(sysctl -n kern.securelevel 2>/dev/null) || _level="-1"
		echo "securelevel=$_level"
		;;
	*)
		echo "unsupported"
		;;
	esac
}

kernel::security::is_locked() {
	local _os _mode
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		_mode=$(cat /sys/kernel/security/lockdown 2>/dev/null) || return 1
		[[ "$_mode" != *"none"* ]]
		;;
	darwin)
		local _sip
		_sip=$(csrutil status 2>&1)
		[[ "$_sip" == *"enabled"* ]]
		;;
	freebsd|openbsd|netbsd)
		local _level
		_level=$(sysctl -n kern.securelevel 2>/dev/null) || _level="-1"
		(( _level > 0 ))
		;;
	*)
		return 1
		;;
	esac
}

# --- LINUX-ONLY IDENTITY ---

kernel::cmdline() {
	cat /proc/cmdline 2>/dev/null || echo "unknown"
}

kernel::cmdline::get() {
	local _key="$1"
	local _cmdline
	_cmdline=$(cat /proc/cmdline 2>/dev/null) || return 1
	local _pair
	for _pair in $_cmdline; do
		case "$_pair" in
		${_key}=*)
			printf '%s' "${_pair#*=}"
			return 0
			;;
		${_key})
			echo "1"
			return 0
			;;
		esac
	done
	return 1
}

kernel::compression() {
	cat /sys/kernel/compression 2>/dev/null || echo "unknown"
}

kernel::tainted() {
	local _val
	_val=$(cat /proc/sys/kernel/tainted 2>/dev/null) || { echo "unknown"; return 1; }
	if [[ "$_val" == "0" ]]; then
		echo "clean"
		return
	fi
	local _flags="" _tmp="$_val"
	(( _tmp & 1 )) && _flags="${_flags}G(proprietary) "
	(( _tmp & 2 )) && _flags="${_flags}F(out-of-tree) "
	(( _tmp & 4 )) && _flags="${_flags}S(unsigned) "
	(( _tmp & 8 ))&&  _flags="${_flags}X(soft-dirty) "
	(( _tmp & 16 )) && _flags="${_flags}D(died) "
	(( _tmp & 32 )) && _flags="${_flags}W(warned) "
	(( _tmp & 64 )) && _flags="${_flags}C(staging) "
	(( _tmp & 128 )) && _flags="${_flags}A(aged) "
	(( _tmp & 256 )) && _flags="${_flags}O(override) "
	(( _tmp & 512 )) && _flags="${_flags}E(signed) "
	printf '%s (%s)' "$_val" "${_flags% }"
}

# --- SECURITY (LINUX-ONLY) ---

kernel::security::lsm() {
	cat /sys/kernel/security/lsm 2>/dev/null || echo "unknown"
}

kernel::security::dmesg_restrict::get() {
	cat /proc/sys/kernel/dmesg_restrict 2>/dev/null || echo "unknown"
}

kernel::security::dmesg_restrict::set() {
	runtime::is_root || { echo "kernel::security::dmesg_restrict::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/dmesg_restrict
}

kernel::security::kptr_restrict::get() {
	cat /proc/sys/kernel/kptr_restrict 2>/dev/null || echo "unknown"
}

kernel::security::kptr_restrict::set() {
	runtime::is_root || { echo "kernel::security::kptr_restrict::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/kptr_restrict
}

kernel::security::aslr::get() {
	cat /proc/sys/kernel/randomize_va_space 2>/dev/null || echo "unknown"
}

kernel::security::aslr::set() {
	runtime::is_root || { echo "kernel::security::aslr::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/randomize_va_space
}

kernel::security::perf_paranoid::get() {
	cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo "unknown"
}

kernel::security::perf_paranoid::set() {
	runtime::is_root || { echo "kernel::security::perf_paranoid::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/perf_event_paranoid
}

# --- MODULES (EXTENDED) ---

kernel::modules::size() {
	awk '{sum += $2} END{print sum}' /proc/modules 2>/dev/null || echo "0"
}

kernel::modules::info() {
	local _module="$1"
	runtime::has_command modinfo || { echo "unknown"; return 1; }
	modinfo "$_module" 2>/dev/null | awk -F':\s*' '/^(filename|description|author|license|depends|vermagic):/{printf "%s=%s\n", $1, $2}'
}

kernel::modules::depends() {
	local _module="$1"
	runtime::has_command modinfo || { echo ""; return 1; }
	modinfo "$_module" 2>/dev/null | awk -F':\s*' '/^depends:/{print $2}' | tr ',' '\n' | grep -v '^$'
}

# --- MODULE LOADING ---

kernel::modules::load() {
	local _module="$1" _params="${2:-}" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::load: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		if runtime::has_command modprobe; then
			modprobe "$_module" $_params 2>/dev/null
		elif runtime::has_command insmod; then
			local _path
			_path=$(modinfo -n "$_module" 2>/dev/null) || _path="$_module"
			insmod "$_path" $_params 2>/dev/null
		else
			echo "kernel::modules::load: modprobe/insmod not found" >&2
			return 1
		fi
		;;
	freebsd|dragonfly)
		kldload "$_module" 2>/dev/null
		;;
	netbsd|openbsd)
		modload "$_module" 2>/dev/null
		;;
	darwin)
		kextload "$_module" 2>/dev/null
		;;
	*)
		echo "kernel::modules::load: unsupported OS" >&2
		return 1
		;;
	esac
}

kernel::modules::unload() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::unload: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		if runtime::has_command modprobe; then
			modprobe -r "$_module" 2>/dev/null
		elif runtime::has_command rmmod; then
			rmmod "$_module" 2>/dev/null
		else
			echo "kernel::modules::unload: modprobe/rmmod not found" >&2
			return 1
		fi
		;;
	freebsd|dragonfly)
		kldunload "$_module" 2>/dev/null
		;;
	netbsd|openbsd)
		modunload "$_module" 2>/dev/null
		;;
	darwin)
		kextunload "$_module" 2>/dev/null
		;;
	*)
		echo "kernel::modules::unload: unsupported OS" >&2
		return 1
		;;
	esac
}

kernel::modules::reload() {
	local _module="$1"
	kernel::modules::unload "$_module"
	sleep 0.5
	kernel::modules::load "$_module"
}

kernel::modules::params() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		local _dir="/sys/module/${_module}/parameters"
		[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
		local _file _val
		for _file in "$_dir"/*; do
			[[ -f "$_file" ]] || continue
			_val=$(cat "$_file" 2>/dev/null) || continue
			printf '%s=%s\n' "$(basename "$_file")" "$_val"
		done
		;;
	freebsd|netbsd|openbsd)
		sysctl -a 2>/dev/null | grep "^${_module}\." || echo "unknown"
		;;
	darwin)
		echo "unsupported"
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::modules::param::get() {
	local _module="$1" _param="$2" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		cat "/sys/module/${_module}/parameters/${_param}" 2>/dev/null || echo "unknown"
		;;
	freebsd|netbsd|openbsd)
		sysctl -n "${_module}.${_param}" 2>/dev/null || echo "unknown"
		;;
	darwin)
		echo "unsupported"
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::modules::param::set() {
	local _module="$1" _param="$2" _value="$3" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::param::set: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		echo "$_value" > "/sys/module/${_module}/parameters/${_param}"
		;;
	freebsd|netbsd|openbsd)
		sysctl "${_module}.${_param}=${_value}" 2>/dev/null
		;;
	darwin)
		echo "kernel::modules::param::set: unsupported on macOS" >&2
		return 1
		;;
	*)
		echo "kernel::modules::param::set: unsupported OS" >&2
		return 1
		;;
	esac
}

kernel::modules::blacklist() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::blacklist: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		echo "blacklist $_module" >> /etc/modprobe.d/blacklist.conf 2>/dev/null || return 1
		;;
	freebsd)
		echo "module_blacklist $_module" >> /boot/loader.conf 2>/dev/null || return 1
		;;
	netbsd|openbsd)
		echo "module $_module disabled" >> /etc/rc.conf 2>/dev/null || return 1
		;;
	darwin)
		echo "kernel::modules::blacklist: unsupported on macOS" >&2
		return 1
		;;
	*)
		echo "kernel::modules::blacklist: unsupported OS" >&2
		return 1
		;;
	esac
}

# --- SYSCTL (cross-platform) ---

kernel::sysctl::get() {
	local _key="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		if [[ -f "/proc/sys/${_key//./\/}" ]]; then
			cat "/proc/sys/${_key//./\/}" 2>/dev/null || echo "unknown"
		else
			echo "unknown"
			return 1
		fi
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl -n "$_key" 2>/dev/null || echo "unknown"
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::sysctl::set() {
	local _key="$1" _value="$2" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::sysctl::set: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		echo "$_value" > "/proc/sys/${_key//./\/}" 2>/dev/null
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl "${_key}=${_value}" 2>/dev/null
		;;
	*)
		echo "kernel::sysctl::set: unsupported OS" >&2
		return 1
		;;
	esac
}

kernel::sysctl::list() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		find /proc/sys -type f 2>/dev/null | sed 's|^/proc/sys/||;s|/|.|g'
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl -a 2>/dev/null | awk -F': ' '{print $1}'
		;;
	*)
		echo "unknown"
		;;
	esac
}

kernel::sysctl::exists() {
	local _key="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		[[ -f "/proc/sys/${_key//./\/}" ]]
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl -n "$_key" >/dev/null 2>&1
		;;
	*)
		return 1
		;;
	esac
}

# --- SLAB ---

kernel::slab::top() {
	local _count="${1:-10}" _dir _name _objects _size
	for _dir in /sys/kernel/slab/*/; do
		[[ -f "$_dir/object_size" && -f "$_dir/objects" ]] || continue
		_objects=$(cat "$_dir/objects" 2>/dev/null) || continue
		_size=$(cat "$_dir/object_size" 2>/dev/null) || continue
		_name=${_dir%/}
		_name=${_name##*/}
		echo "$((_objects * _size)) $_name $_objects $_size"
	done | sort -rn | head -"$_count" | \
		awk '{printf "%-30s objects=%-10s size=%-8s total=%s\n", $2, $3, $4, $1}'
}

kernel::slab::total_memory() {
	local _dir _objects _size _total=0
	for _dir in /sys/kernel/slab/*/; do
		[[ -f "$_dir/object_size" && -f "$_dir/objects" ]] || continue
		_objects=$(cat "$_dir/objects" 2>/dev/null) || continue
		_size=$(cat "$_dir/object_size" 2>/dev/null) || continue
		_total=$((_total + _objects * _size))
	done
	echo "$((_total / 1024))"
}

kernel::slab::cache_info() {
	local _cache="$1" _dir="/sys/kernel/slab/$_cache"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _objects _size _slabs _ctor
	_objects=$(cat "$_dir/objects" 2>/dev/null) || _objects="?"
	_size=$(cat "$_dir/object_size" 2>/dev/null) || _size="?"
	_slabs=$(cat "$_dir/slabs" 2>/dev/null) || _slabs="?"
	_ctor=$(cat "$_dir/ctor" 2>/dev/null) || _ctor=""
	printf 'objects=%s object_size=%s slabs=%s' "$_objects" "$_size" "$_slabs"
	[[ -n "$_ctor" && "$_ctor" != "0" && "$_ctor" != "" ]] && printf ' ctor=%s' "$_ctor"
	echo
}

# --- IRQ ---

kernel::irq::list() {
	local _irq _dir _action _chip _type _count
	for _dir in /sys/kernel/irq/[0-9]*/; do
		[[ -d "$_dir" ]] || continue
		_irq=${_dir%/}
		_irq=${_irq##*/}
		_action=$(cat "$_dir/actions" 2>/dev/null) || continue
		_chip=$(cat "$_dir/chip_name" 2>/dev/null) || _chip="?"
		_type=$(cat "$_dir/type" 2>/dev/null) || __type="?"
		_count=$(cat "$_dir/per_cpu_count" 2>/dev/null) || __count="?"
		printf '%-6s %-20s %-20s %-10s %s\n' "$_irq" "$_action" "$_chip" "$_type" "$_count"
	done
}

kernel::irq::busiest() {
	local _count="${1:-10}" _irq _dir _action _total _all
	_all=""
	for _dir in /sys/kernel/irq/[0-9]*/; do
		[[ -d "$_dir" ]] || continue
		_irq=${_dir%/}
		_irq=${_irq##*/}
		_action=$(cat "$_dir/actions" 2>/dev/null) || continue
		_total=$(cat "$_dir/per_cpu_count" 2>/dev/null) || _total=0
		# Sum all per_cpu_count values
		_total=0
		local _val
		_val=$(cat "$_dir/per_cpu_count" 2>/dev/null) || _val="0"
		_total=0
		local _n
		for _n in $_val; do
			_total=$((_total + _n))
		done
		_all="${_all}${_total} ${_irq} ${_action}\n"
	done
	printf "$_all" | sort -rn | head -"$_count" | \
		awk '{printf "%-6s %-20s %s\n", $2, $3, $1}'
}

kernel::irq::info() {
	local _irq="$1" _dir="/sys/kernel/irq/$_irq"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _action _chip _hwirq _type _count _name
	_action=$(cat "$_dir/actions" 2>/dev/null) || _action="?"
	_chip=$(cat "$_dir/chip_name" 2>/dev/null) || _chip="?"
	_hwirq=$(cat "$_dir/hwirq" 2>/dev/null) || _hwirq="?"
	_type=$(cat "$_dir/type" 2>/dev/null) || _type="?"
	_count=$(cat "$_dir/per_cpu_count" 2>/dev/null) || _count="?"
	_name=$(cat "$_dir/name" 2>/dev/null) || _name=""
	printf 'irq=%s action=%s chip=%s hwirq=%s type=%s count=%s\n' \
		"$_irq" "$_action" "$_chip" "$_hwirq" "$_type" "$_count"
	[[ -n "$_name" ]] && printf 'name=%s\n' "$_name"
}

kernel::irq::by_device() {
	local _pattern="$1" _irq _dir _action
	for _dir in /sys/kernel/irq/[0-9]*/; do
		[[ -d "$_dir" ]] || continue
		_irq=${_dir%/}
		_irq=${_irq##*/}
		_action=$(cat "$_dir/actions" 2>/dev/null) || continue
		[[ "$_action" == *"$_pattern"* ]] && kernel::irq::info "$_irq"
	done
}

kernel::irq::affinity() {
	local _irq="$1"
	cat "/proc/irq/$_irq/smp_affinity_list" 2>/dev/null || echo "unknown"
}

kernel::irq::effective_affinity() {
	local _irq="$1"
	cat "/proc/irq/$_irq/effective_affinity_list" 2>/dev/null || echo "unknown"
}

kernel::irq::spurious() {
	local _irq="$1"
	awk '/^count/{printf "count=%s ", $2} /^unhandled/{printf "unhandled=%s ", $2} /^last_unhandled/{printf "last=%s %s", $2, $3}' \
		"/proc/irq/$_irq/spurious" 2>/dev/null || echo "unknown"
}

kernel::irq::set_affinity() {
	local _irq="$1" _mask="$2"
	runtime::is_root || { echo "kernel::irq::set_affinity: requires root" >&2; return 1; }
	echo "$_mask" > "/proc/irq/$_irq/smp_affinity"
}

kernel::irq::set_affinity_list() {
	local _irq="$1" _list="$2"
	runtime::is_root || { echo "kernel::irq::set_affinity_list: requires root" >&2; return 1; }
	echo "$_list" > "/proc/irq/$_irq/smp_affinity_list"
}

# --- POWER MANAGEMENT ---

kernel::power::states() {
	cat /sys/power/state 2>/dev/null || echo "unknown"
}

kernel::power::can_suspend() {
	local _states
	_states=$(cat /sys/power/state 2>/dev/null) || return 1
	[[ "$_states" == *"mem"* ]]
}

kernel::power::can_hibernate() {
	local _states
	_states=$(cat /sys/power/state 2>/dev/null) || return 1
	[[ "$_states" == *"disk"* ]]
}

kernel::power::suspend() {
	runtime::is_root || { echo "kernel::power::suspend: requires root" >&2; return 1; }
	echo mem > /sys/power/state
}

kernel::power::hibernate() {
	runtime::is_root || { echo "kernel::power::hibernate: requires root" >&2; return 1; }
	echo disk > /sys/power/state
}

kernel::power::mem_sleep::get() {
	cat /sys/power/mem_sleep 2>/dev/null || echo "unknown"
}

kernel::power::mem_sleep::set() {
	runtime::is_root || { echo "kernel::power::mem_sleep::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/mem_sleep
}

kernel::power::pm_async::get() {
	cat /sys/power/pm_async 2>/dev/null || echo "unknown"
}

kernel::power::pm_async::set() {
	runtime::is_root || { echo "kernel::power::pm_async::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_async
}

kernel::power::sync_on_suspend::get() {
	cat /sys/power/sync_on_suspend 2>/dev/null || echo "unknown"
}

kernel::power::sync_on_suspend::set() {
	runtime::is_root || { echo "kernel::power::sync_on_suspend::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/sync_on_suspend
}

kernel::power::freeze_timeout::get() {
	cat /sys/power/pm_freeze_timeout 2>/dev/null || echo "unknown"
}

kernel::power::freeze_timeout::set() {
	runtime::is_root || { echo "kernel::power::freeze_timeout::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_freeze_timeout
}

kernel::power::debug_messages::get() {
	cat /sys/power/pm_debug_messages 2>/dev/null || echo "unknown"
}

kernel::power::debug_messages::set() {
	runtime::is_root || { echo "kernel::power::debug_messages::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_debug_messages
}

kernel::power::print_times::get() {
	cat /sys/power/pm_print_times 2>/dev/null || echo "unknown"
}

kernel::power::print_times::set() {
	runtime::is_root || { echo "kernel::power::print_times::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_print_times
}

kernel::power::pm_trace::get() {
	cat /sys/power/pm_trace 2>/dev/null || echo "unknown"
}

kernel::power::pm_trace::set() {
	runtime::is_root || { echo "kernel::power::pm_trace::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_trace
}

kernel::power::freeze_filesystems::get() {
	cat /sys/power/freeze_filesystems 2>/dev/null || echo "unknown"
}

kernel::power::freeze_filesystems::set() {
	runtime::is_root || { echo "kernel::power::freeze_filesystems::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/freeze_filesystems
}

kernel::power::image_size::get() {
	cat /sys/power/image_size 2>/dev/null || echo "unknown"
}

kernel::power::image_size::set() {
	runtime::is_root || { echo "kernel::power::image_size::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/image_size
}

kernel::power::reserved_size::get() {
	cat /sys/power/reserved_size 2>/dev/null || echo "unknown"
}

kernel::power::reserved_size::set() {
	runtime::is_root || { echo "kernel::power::reserved_size::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/reserved_size
}

kernel::power::hibernate_compression_threads::get() {
	cat /sys/power/hibernate_compression_threads 2>/dev/null || echo "unknown"
}

kernel::power::hibernate_compression_threads::set() {
	runtime::is_root || { echo "kernel::power::hibernate_compression_threads::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/hibernate_compression_threads
}

kernel::power::disk_mode::get() {
	cat /sys/power/disk 2>/dev/null || echo "unknown"
}

kernel::power::disk_mode::set() {
	runtime::is_root || { echo "kernel::power::disk_mode::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/disk
}

kernel::power::resume_device::set() {
	runtime::is_root || { echo "kernel::power::resume_device::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/resume
}

kernel::power::resume_offset::get() {
	cat /sys/power/resume_offset 2>/dev/null || echo "unknown"
}

kernel::power::resume_offset::set() {
	runtime::is_root || { echo "kernel::power::resume_offset::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/resume_offset
}

kernel::power::pm_test::set() {
	runtime::is_root || { echo "kernel::power::pm_test::set: requires root" >&2; return 1; }
	echo "$1" > /sys/power/pm_test
}

kernel::power::suspend_stats() {
	local _dir="/sys/power/suspend_stats"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _success _fail _reason
	_success=$(cat "$_dir/success" 2>/dev/null) || _success=0
	_fail=$(cat "$_dir/fail" 2>/dev/null) || _fail=0
	_reason=$(cat "$_dir/last_failed_step" 2>/dev/null) || _reason=""
	printf 'success=%s fail=%s' "$_success" "$_fail"
	[[ -n "$_reason" ]] && printf ' last_failed_step=%s' "$_reason"
	echo
}

kernel::power::wakeup_count() {
	cat /sys/power/wakeup_count 2>/dev/null || echo "unknown"
}

# --- KEXEC / REBOOT ---

kernel::kexec::loaded() {
	local _val
	_val=$(cat /sys/kernel/kexec/loaded 2>/dev/null) || { echo "unknown"; return 1; }
	[[ "$_val" == "1" ]]
}

kernel::kexec::crash::loaded() {
	local _val
	_val=$(cat /sys/kernel/kexec/crash_loaded 2>/dev/null) || { echo "unknown"; return 1; }
	[[ "$_val" == "1" ]]
}

kernel::kexec::crash::size() {
	local _bytes
	_bytes=$(cat /sys/kernel/kexec/crash_size 2>/dev/null) || { echo "unknown"; return 1; }
	if (( _bytes >= 1073741824 )); then
		printf '%.1fGB' "$((_bytes / 1073741824))"
	elif (( _bytes >= 1048576 )); then
		printf '%.1fMB' "$((_bytes / 1048576))"
	else
		echo "${_bytes}kB"
	fi
}

kernel::reboot::mode() {
	cat /sys/kernel/reboot/mode 2>/dev/null || echo "unknown"
}

kernel::reboot::type() {
	cat /sys/kernel/reboot/type 2>/dev/null || echo "unknown"
}

kernel::reboot::force() {
	local _val
	_val=$(cat /sys/kernel/reboot/force 2>/dev/null) || { echo "unknown"; return 1; }
	[[ "$_val" == "1" ]]
}

# --- SCHEDULER ---

kernel::sched::ext::status() {
	local _state _seq _rejected
	_state=$(cat /sys/kernel/sched_ext/state 2>/dev/null) || { echo "unknown"; return 1; }
	_seq=$(cat /sys/kernel/sched_ext/enable_seq 2>/dev/null) || _seq="?"
	_rejected=$(cat /sys/kernel/sched_ext/nr_rejected 2>/dev/null) || _rejected="?"
	printf 'state=%s seq=%s rejected=%s\n' "$_state" "$_seq" "$_rejected"
}

kernel::sched::ext::is_active() {
	local _state
	_state=$(cat /sys/kernel/sched_ext/state 2>/dev/null) || return 1
	[[ "$_state" != "disabled" ]]
}

# --- CGROUP ---

kernel::cgroup::features() {
	cat /sys/kernel/cgroup/features 2>/dev/null || echo "unknown"
}

kernel::cgroup::delegate() {
	cat /sys/kernel/cgroup/delegate 2>/dev/null || echo "unknown"
}

kernel::cgroup::is_enabled() {
	local _feature="$1" _features
	_features=$(cat /sys/kernel/cgroup/features 2>/dev/null) || return 1
	[[ "$_features" == *"$_feature"* ]]
}

kernel::cgroup::stat() {
	local _dir="/sys/fs/cgroup"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _descendants _dying
	_descendants=$(cat "$_dir/cgroup.stat" 2>/dev/null | awk '/nr_descendants/{print $2}') || _descendants="?"
	_dying=$(cat "$_dir/cgroup.stat" 2>/dev/null | awk '/nr_dying_descendants/{print $2}') || _dying="?"
	printf 'descendants=%s dying=%s\n' "$_descendants" "$_dying"
}

kernel::cgroup::cpu_stat() {
	local _dir="/sys/fs/cgroup"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	awk '/^usage_usec|^user_usec|^system_usec|^nr_periods|^nr_throttled|^throttled_usec/{printf "%s ", $0}' \
		"$_dir/cpu.stat" 2>/dev/null || echo "unknown"
	echo
}

kernel::cgroup::cpu_pressure() {
	cat /sys/fs/cgroup/cpu.pressure 2>/dev/null || echo "unknown"
}

kernel::cgroup::memory_stat() {
	cat /sys/fs/cgroup/memory.stat 2>/dev/null || echo "unknown"
}

kernel::cgroup::io_stat() {
	cat /sys/fs/cgroup/io.stat 2>/dev/null || echo "unknown"
}

kernel::cgroup::io_pressure() {
	cat /sys/fs/cgroup/io.pressure 2>/dev/null || echo "unknown"
}

kernel::cgroup::move_process() {
	local _pid="$1"
	runtime::is_root || { echo "kernel::cgroup::move_process: requires root" >&2; return 1; }
	echo "$_pid" > /sys/fs/cgroup/cgroup.procs
}

kernel::cgroup::reclaim_memory() {
	local _bytes="${1:-0}"
	runtime::is_root || { echo "kernel::cgroup::reclaim_memory: requires root" >&2; return 1; }
	echo "$_bytes" > /sys/fs/cgroup/memory.reclaim
}

# --- SYSLOG ---

kernel::syslog::read() {
	local _level="${1:-}"
	if [[ -n "$_level" ]]; then
		dmesg --level="$_level" 2>/dev/null || dmesg 2>/dev/null
	else
		dmesg 2>/dev/null
	fi
}

kernel::syslog::last() {
	local _count="${1:-50}"
	dmesg 2>/dev/null | tail -"$_count"
}

kernel::syslog::errors() {
	dmesg --level=err,crit,alert,emerg 2>/dev/null || \
		dmesg 2>/dev/null | grep -iE 'err|crit|alert|emerg'
}

kernel::syslog::level() {
	awk '{print $1, $2, $3, $4}' /proc/sys/kernel/printk 2>/dev/null || echo "unknown"
}

kernel::syslog::since() {
	local _time="$1"
	[[ -z "$_time" ]] && { kernel::syslog::last; return; }
	dmesg -T 2>/dev/null | awk -v t="$_time" '$0>=t' || dmesg 2>/dev/null
}

# --- SYSRQ ---

kernel::sysrq::enabled() {
	local _val
	_val=$(cat /proc/sys/kernel/sysrq 2>/dev/null) || { echo "unknown"; return 1; }
	if [[ "$_val" == "1" ]]; then
		echo "enabled (all)"
	elif [[ "$_val" == "0" ]]; then
		echo "disabled"
	else
		local _flags=""
		(( _val & 1 )) && _flags="${_flags}r(read) "
		(( _val & 2 )) && _flags="${_flags}k(SAK) "
		(( _val & 4 )) && _flags="${_flags}b(reboot) "
		(( _val & 8 )) && _flags="${_flags}o(poweroff) "
		(( _val & 16 )) && _flags="${_flags}s(sync) "
		(( _val & 32 )) && _flags="${_flags}t(tasks) "
		(( _val & 64 )) && _flags="${_flags}m(mount) "
		(( _val & 128 )) && _flags="${_flags}n(nice) "
		(( _val & 256 )) && _flags="${_flags}p(dump) "
		(( _val & 512 )) && _flags="${_flags}u(unicode) "
		(( _val & 1024 )) && _flags="${_flags}v(vt) "
		printf 'partial (%s) mask=%s\n' "${_flags% }" "$_val"
	fi
}

kernel::sysrq::sync() {
	runtime::is_root || { echo "kernel::sysrq::sync: requires root" >&2; return 1; }
	echo s > /proc/sysrq-trigger
}

kernel::sysrq::show_tasks() {
	runtime::is_root || { echo "kernel::sysrq::show_tasks: requires root" >&2; return 1; }
	echo t > /proc/sysrq-trigger
	dmesg 2>/dev/null | tail -100
}

kernel::sysrq::show_memory() {
	runtime::is_root || { echo "kernel::sysrq::show_memory: requires root" >&2; return 1; }
	echo m > /proc/sysrq-trigger
	dmesg 2>/dev/null | tail -100
}

kernel::sysrq::reboot() {
	runtime::is_root || { echo "kernel::sysrq::reboot: requires root" >&2; return 1; }
	echo b > /proc/sysrq-trigger
}

kernel::sysrq::poweroff() {
	runtime::is_root || { echo "kernel::sysrq::poweroff: requires root" >&2; return 1; }
	echo o > /proc/sysrq-trigger
}

kernel::sysrq::oom_kill() {
	echo f > /proc/sysrq-trigger 2>/dev/null
}

# --- VMSTAT ---

kernel::vmstat::get() {
	local _key="$1"
	awk -v k="$_key" '$1==k{print $2}' /proc/vmstat 2>/dev/null || echo "unknown"
}

kernel::vmstat::pgfault() {
	awk '/^pgfault/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}

kernel::vmstat::pgmajfault() {
	awk '/^pgmajfault/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}

kernel::vmstat::pswpin() {
	awk '/^pswpin/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}

kernel::vmstat::pswpout() {
	awk '/^pswpout/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}

kernel::vmstat::compact_stall() {
	awk '/^compact_stall/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}

kernel::vmstat::thp_fault_alloc() {
	awk '/^thp_fault_alloc/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}

kernel::vmstat::summary() {
	local _line
	while IFS= read -r _line; do
		case "$_line" in
		pgfault|pgmajfault|pswpin|pswpout|pgpgin|pgpgout|\
		compact_stall|thp_fault_alloc|thp_collapse_alloc|\
		kswapd_inodesteal|kswapd_low_wmark_hit_quickly|\
		kswapd_high_wmark_hit_quickly|pageoutrun|allocstall|\
		pgmajfault|workingset_refault|workingset_activate|\
		_workingset_restore|pagealloc_normal|pagealloc_movable|\
		zone_reclaim_failed|pgscan_kswapd|pgscan_direct|\
		pgsteal_kswapd|pgsteal_direct|pgscan_anon|pgscan_file|\
		pgsteal_anon|pgsteal_file)
			printf '%s=%s ' "${_line%% *}" "${_line##* }"
			;;
		esac
	done < /proc/vmstat 2>/dev/null
	echo
}

# --- BUDDYINFO ---

kernel::buddyinfo::free_pages() {
	local _total=0 _line _val
	while IFS= read -r _line; do
		for _val in $_line; do
			[[ "$_val" =~ ^[0-9]+$ ]] && _total=$((_total + _val))
		done
	done < /proc/buddyinfo 2>/dev/null
	echo "$_total"
}

kernel::buddyinfo::fragmentation() {
	local _zone _order _count _total _frag
	while read -r _zone _rest; do
		_zone=${_zone##*:}
		_zone=${_zone# }
		set -- $_rest
		_total=0
		for _order in "${!_rest[@]}"; do
			_count=${_rest[$_order]}
			_total=$((_total + _count))
		done
		if (( _total > 0 )); then
			printf '%s: total=%s\n' "$_zone" "$_total"
			_order=0
			for _count in "${_rest[@]}"; do
				_frag=$(( _count * 100 / _total ))
				printf '  order %s: %s (%s%%)\n' "$_order" "$_count" "$_frag"
				_order=$((_order + 1))
			done
		fi
	done < /proc/buddyinfo 2>/dev/null
}

# --- MEMINFO (EXTENDED) ---

kernel::meminfo::buffers() {
	awk '/^Buffers:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}

kernel::meminfo::cached() {
	awk '/^Cached:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}

kernel::meminfo::swap_total() {
	awk '/^SwapTotal:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}

kernel::meminfo::swap_free() {
	awk '/^SwapFree:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}

kernel::meminfo::swap_used() {
	local _total _free
	_total=$(awk '/^SwapTotal:/{print $2}' /proc/meminfo 2>/dev/null) || { echo "unknown"; return 1; }
	_free=$(awk '/^SwapFree:/{print $2}' /proc/meminfo 2>/dev/null) || { echo "unknown"; return 1; }
	echo $((_total - _free)) | awk '{printf "%.0f", $1/1024}'
}

kernel::meminfo::slab() {
	awk '/^Slab:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}

kernel::meminfo::summary() {
	local _total _avail _used _free _buffers _cached _swap_t _swap_f _slab
	_total=$(kernel::meminfo::total)
	_free=$(kernel::meminfo::free)
	_buffers=$(kernel::meminfo::buffers)
	_cached=$(kernel::meminfo::cached)
	_slab=$(kernel::meminfo::slab)
	_swap_t=$(kernel::meminfo::swap_total)
	_swap_f=$(kernel::meminfo::swap_free)
	printf 'total=%sMB free=%sMB buffers=%sMB cached=%sMB slab=%sMB swap_total=%sMB swap_free=%sMB\n' \
		"${_total:-?}" "${_free:-?}" "${_buffers:-?}" "${_cached:-?}" "${_slab:-?}" "${_swap_t:-?}" "${_swap_f:-?}"
}

# --- /proc/sys/kernel TUNABLES ---

kernel::pid_max::get() {
	cat /proc/sys/kernel/pid_max 2>/dev/null || echo "unknown"
}

kernel::pid_max::set() {
	runtime::is_root || { echo "kernel::pid_max::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/pid_max
}

kernel::threads_max::get() {
	cat /proc/sys/kernel/threads-max 2>/dev/null || echo "unknown"
}

kernel::threads_max::set() {
	runtime::is_root || { echo "kernel::threads_max::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/threads-max
}

kernel::sysrq::enabled::get() {
	cat /proc/sys/kernel/sysrq 2>/dev/null || echo "unknown"
}

kernel::sysrq::enabled::set() {
	runtime::is_root || { echo "kernel::sysrq::enabled::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/sysrq
}

kernel::panic::timeout::get() {
	cat /proc/sys/kernel/panic 2>/dev/null || echo "unknown"
}

kernel::panic::timeout::set() {
	runtime::is_root || { echo "kernel::panic::timeout::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/panic
}

kernel::panic::on_oops::get() {
	cat /proc/sys/kernel/panic_on_oops 2>/dev/null || echo "unknown"
}

kernel::panic::on_oops::set() {
	runtime::is_root || { echo "kernel::panic::on_oops::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/panic_on_oops
}

kernel::coredump::pattern::get() {
	cat /proc/sys/kernel/core_pattern 2>/dev/null || echo "unknown"
}

kernel::coredump::pattern::set() {
	runtime::is_root || { echo "kernel::coredump::pattern::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_pattern
}

kernel::coredump::uses_pid::get() {
	cat /proc/sys/kernel/core_uses_pid 2>/dev/null || echo "unknown"
}

kernel::coredump::uses_pid::set() {
	runtime::is_root || { echo "kernel::coredump::uses_pid::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_uses_pid
}

kernel::coredump::note_size_limit::get() {
	cat /proc/sys/kernel/core_file_note_size_limit 2>/dev/null || echo "unknown"
}

kernel::coredump::note_size_limit::set() {
	runtime::is_root || { echo "kernel::coredump::note_size_limit::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_file_note_size_limit
}

kernel::coredump::sort_vma::get() {
	cat /proc/sys/kernel/core_sort_vma 2>/dev/null || echo "unknown"
}

kernel::coredump::sort_vma::set() {
	runtime::is_root || { echo "kernel::coredump::sort_vma::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_sort_vma
}

kernel::ctrl_alt_del::get() {
	cat /proc/sys/kernel/ctrl-alt-del 2>/dev/null || echo "unknown"
}

kernel::ctrl_alt_del::set() {
	runtime::is_root || { echo "kernel::ctrl_alt_del::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/ctrl-alt-del
}

kernel::domainname::get() {
	cat /proc/sys/kernel/domainname 2>/dev/null || echo "unknown"
}

kernel::domainname::set() {
	runtime::is_root || { echo "kernel::domainname::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/domainname
}

kernel::ftrace::dump_on_oops::get() {
	cat /proc/sys/kernel/ftrace_dump_on_oops 2>/dev/null || echo "unknown"
}

kernel::ftrace::dump_on_oops::set() {
	runtime::is_root || { echo "kernel::ftrace::dump_on_oops::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/ftrace_dump_on_oops
}

kernel::ftrace::enabled::get() {
	cat /proc/sys/kernel/ftrace_enabled 2>/dev/null || echo "unknown"
}

kernel::ftrace::enabled::set() {
	runtime::is_root || { echo "kernel::ftrace::enabled::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/ftrace_enabled
}

kernel::lockup::hardlockup_backtrace::get() {
	cat /proc/sys/kernel/hardlockup_all_cpu_backtrace 2>/dev/null || echo "unknown"
}

kernel::lockup::hardlockup_backtrace::set() {
	runtime::is_root || { echo "kernel::lockup::hardlockup_backtrace::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/hardlockup_all_cpu_backtrace
}

kernel::lockup::hardlockup_panic::get() {
	cat /proc/sys/kernel/hardlockup_panic 2>/dev/null || echo "unknown"
}

kernel::lockup::hardlockup_panic::set() {
	runtime::is_root || { echo "kernel::lockup::hardlockup_panic::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/hardlockup_panic
}

kernel::lockup::hung_task_backtrace::get() {
	cat /proc/sys/kernel/hung_task_all_cpu_backtrace 2>/dev/null || echo "unknown"
}

kernel::lockup::hung_task_backtrace::set() {
	runtime::is_root || { echo "kernel::lockup::hung_task_backtrace::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/hung_task_all_cpu_backtrace
}

kernel::ipc::auto_msgmni::get() {
	cat /proc/sys/kernel/auto_msgmni 2>/dev/null || echo "unknown"
}

kernel::ipc::auto_msgmni::set() {
	runtime::is_root || { echo "kernel::ipc::auto_msgmni::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/auto_msgmni
}

kernel::bpf::stats_enabled::get() {
	cat /proc/sys/kernel/bpf_stats_enabled 2>/dev/null || echo "unknown"
}

kernel::bpf::stats_enabled::set() {
	runtime::is_root || { echo "kernel::bpf::stats_enabled::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/bpf_stats_enabled
}

kernel::acpi::video_flags::get() {
	cat /proc/sys/kernel/acpi_video_flags 2>/dev/null || echo "unknown"
}

kernel::acpi::video_flags::set() {
	runtime::is_root || { echo "kernel::acpi::video_flags::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/acpi_video_flags
}

kernel::acct::interval::get() {
	cat /proc/sys/kernel/acct 2>/dev/null || echo "unknown"
}

kernel::acct::interval::set() {
	runtime::is_root || { echo "kernel::acct::interval::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/acct
}

kernel::ns::last_pid::set() {
	runtime::is_root || { echo "kernel::ns::last_pid::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/ns_last_pid
}

# --- /proc/sys/vm TUNABLES ---

kernel::vm::cache::drop() {
	runtime::is_root || { echo "kernel::vm::cache::drop: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/drop_caches
}

kernel::vm::compact() {
	runtime::is_root || { echo "kernel::vm::compact: requires root" >&2; return 1; }
	echo 1 > /proc/sys/vm/compact_memory
}

kernel::vm::dirty_ratio::get() {
	cat /proc/sys/vm/dirty_ratio 2>/dev/null || echo "unknown"
}

kernel::vm::dirty_ratio::set() {
	runtime::is_root || { echo "kernel::vm::dirty_ratio::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_ratio
}

kernel::vm::dirty_background_ratio::get() {
	cat /proc/sys/vm/dirty_background_ratio 2>/dev/null || echo "unknown"
}

kernel::vm::dirty_background_ratio::set() {
	runtime::is_root || { echo "kernel::vm::dirty_background_ratio::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_background_ratio
}

kernel::vm::dirty_bytes::get() {
	cat /proc/sys/vm/dirty_bytes 2>/dev/null || echo "unknown"
}

kernel::vm::dirty_bytes::set() {
	runtime::is_root || { echo "kernel::vm::dirty_bytes::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_bytes
}

kernel::vm::dirty_background_bytes::get() {
	cat /proc/sys/vm/dirty_background_bytes 2>/dev/null || echo "unknown"
}

kernel::vm::dirty_background_bytes::set() {
	runtime::is_root || { echo "kernel::vm::dirty_background_bytes::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_background_bytes
}

kernel::vm::dirty_expire::get() {
	cat /proc/sys/vm/dirty_expire_centisecs 2>/dev/null || echo "unknown"
}

kernel::vm::dirty_expire::set() {
	runtime::is_root || { echo "kernel::vm::dirty_expire::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_expire_centisecs
}

kernel::vm::dirty_writeback::get() {
	cat /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null || echo "unknown"
}

kernel::vm::dirty_writeback::set() {
	runtime::is_root || { echo "kernel::vm::dirty_writeback::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirty_writeback_centisecs
}

kernel::vm::swappiness::get() {
	cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown"
}

kernel::vm::swappiness::set() {
	runtime::is_root || { echo "kernel::vm::swappiness::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/swappiness
}

kernel::vm::min_free::get() {
	cat /proc/sys/vm/min_free_kbytes 2>/dev/null || echo "unknown"
}

kernel::vm::min_free::set() {
	runtime::is_root || { echo "kernel::vm::min_free::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/min_free_kbytes
}

kernel::vm::max_map_count::get() {
	cat /proc/sys/vm/max_map_count 2>/dev/null || echo "unknown"
}

kernel::vm::max_map_count::set() {
	runtime::is_root || { echo "kernel::vm::max_map_count::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/max_map_count
}

kernel::vm::vfs_cache_pressure::get() {
	cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo "unknown"
}

kernel::vm::vfs_cache_pressure::set() {
	runtime::is_root || { echo "kernel::vm::vfs_cache_pressure::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/vfs_cache_pressure
}

kernel::vm::laptop_mode::get() {
	cat /proc/sys/vm/laptop_mode 2>/dev/null || echo "unknown"
}

kernel::vm::laptop_mode::set() {
	runtime::is_root || { echo "kernel::vm::laptop_mode::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/laptop_mode
}

kernel::vm::compaction_proactiveness::get() {
	cat /proc/sys/vm/compaction_proactiveness 2>/dev/null || echo "unknown"
}

kernel::vm::compaction_proactiveness::set() {
	runtime::is_root || { echo "kernel::vm::compaction_proactiveness::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/compaction_proactiveness
}

kernel::vm::overcommit::memory::get() {
	cat /proc/sys/vm/overcommit_memory 2>/dev/null || echo "unknown"
}

kernel::vm::overcommit::memory::set() {
	runtime::is_root || { echo "kernel::vm::overcommit::memory::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/overcommit_memory
}

kernel::vm::overcommit::ratio::get() {
	cat /proc/sys/vm/overcommit_ratio 2>/dev/null || echo "unknown"
}

kernel::vm::overcommit::ratio::set() {
	runtime::is_root || { echo "kernel::vm::overcommit::ratio::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/overcommit_ratio
}

kernel::vm::admin_reserve::get() {
	cat /proc/sys/vm/admin_reserve_kbytes 2>/dev/null || echo "unknown"
}

kernel::vm::admin_reserve::set() {
	runtime::is_root || { echo "kernel::vm::admin_reserve::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/admin_reserve_kbytes
}

kernel::vm::mmap_min_addr::get() {
	cat /proc/sys/vm/mmap_min_addr 2>/dev/null || echo "unknown"
}

kernel::vm::mmap_min_addr::set() {
	runtime::is_root || { echo "kernel::vm::mmap_min_addr::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/mmap_min_addr
}

kernel::vm::mmap_rnd_bits::get() {
	cat /proc/sys/vm/mmap_rnd_bits 2>/dev/null || echo "unknown"
}

kernel::vm::mmap_rnd_bits::set() {
	runtime::is_root || { echo "kernel::vm::mmap_rnd_bits::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/mmap_rnd_bits
}

kernel::vm::hugetlb::shm_group::get() {
	cat /proc/sys/vm/hugetlb_shm_group 2>/dev/null || echo "unknown"
}

kernel::vm::hugetlb::shm_group::set() {
	runtime::is_root || { echo "kernel::vm::hugetlb::shm_group::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/hugetlb_shm_group
}

kernel::vm::hugetlb::optimize_vmemmap::get() {
	cat /proc/sys/vm/hugetlb_optimize_vmemmap 2>/dev/null || echo "unknown"
}

kernel::vm::hugetlb::optimize_vmemmap::set() {
	runtime::is_root || { echo "kernel::vm::hugetlb::optimize_vmemmap::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/hugetlb_optimize_vmemmap
}

kernel::vm::extfrag_threshold::get() {
	cat /proc/sys/vm/extfrag_threshold 2>/dev/null || echo "unknown"
}

kernel::vm::extfrag_threshold::set() {
	runtime::is_root || { echo "kernel::vm::extfrag_threshold::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/extfrag_threshold
}

kernel::vm::soft_offline::get() {
	cat /proc/sys/vm/enable_soft_offline 2>/dev/null || echo "unknown"
}

kernel::vm::soft_offline::set() {
	runtime::is_root || { echo "kernel::vm::soft_offline::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/enable_soft_offline
}

kernel::vm::compact_unevictable::get() {
	cat /proc/sys/vm/compact_unevictable_allowed 2>/dev/null || echo "unknown"
}

kernel::vm::compact_unevictable::set() {
	runtime::is_root || { echo "kernel::vm::compact_unevictable::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/compact_unevictable_allowed
}

kernel::vm::defrag_mode::get() {
	cat /proc/sys/vm/defrag_mode 2>/dev/null || echo "unknown"
}

kernel::vm::defrag_mode::set() {
	runtime::is_root || { echo "kernel::vm::defrag_mode::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/defrag_mode
}

kernel::vm::dirtytime_expire::get() {
	cat /proc/sys/vm/dirtytime_expire_seconds 2>/dev/null || echo "unknown"
}

kernel::vm::dirtytime_expire::set() {
	runtime::is_root || { echo "kernel::vm::dirtytime_expire::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/dirtytime_expire_seconds
}

kernel::vm::memory_failure::early_kill::get() {
	cat /proc/sys/vm/memory_failure_early_kill 2>/dev/null || echo "unknown"
}

kernel::vm::memory_failure::early_kill::set() {
	runtime::is_root || { echo "kernel::vm::memory_failure::early_kill::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/memory_failure_early_kill
}

kernel::vm::memory_failure::recovery::get() {
	cat /proc/sys/vm/memory_failure_recovery 2>/dev/null || echo "unknown"
}

kernel::vm::memory_failure::recovery::set() {
	runtime::is_root || { echo "kernel::vm::memory_failure::recovery::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/memory_failure_recovery
}

kernel::memfd::noexec::get() {
	cat /proc/sys/vm/memfd_noexec 2>/dev/null || echo "unknown"
}

kernel::memfd::noexec::set() {
	runtime::is_root || { echo "kernel::memfd::noexec::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/memfd_noexec
}

kernel::vm::lowmem_reserve::get() {
	cat /proc/sys/vm/lowmem_reserve_ratio 2>/dev/null || echo "unknown"
}

kernel::vm::lowmem_reserve::set() {
	runtime::is_root || { echo "kernel::vm::lowmem_reserve::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/lowmem_reserve_ratio
}

kernel::vm::min_slab_ratio::get() {
	cat /proc/sys/vm/min_slab_ratio 2>/dev/null || echo "unknown"
}

kernel::vm::min_slab_ratio::set() {
	runtime::is_root || { echo "kernel::vm::min_slab_ratio::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/min_slab_ratio
}

kernel::vm::min_unmapped_ratio::get() {
	cat /proc/sys/vm/min_unmapped_ratio 2>/dev/null || echo "unknown"
}

kernel::vm::min_unmapped_ratio::set() {
	runtime::is_root || { echo "kernel::vm::min_unmapped_ratio::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/min_unmapped_ratio
}

kernel::vm::legacy_va_layout::get() {
	cat /proc/sys/vm/legacy_va_layout 2>/dev/null || echo "unknown"
}

kernel::vm::legacy_va_layout::set() {
	runtime::is_root || { echo "kernel::vm::legacy_va_layout::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/legacy_va_layout
}

kernel::vm::movable_gigantic::get() {
	cat /proc/sys/vm/movable_gigantic_pages 2>/dev/null || echo "unknown"
}

kernel::vm::movable_gigantic::set() {
	runtime::is_root || { echo "kernel::vm::movable_gigantic::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/vm/movable_gigantic_pages
}

# --- BSD (FreeBSD/OpenBSD/NetBSD) ---

_kernel::bsd::persist_sysctl() {
	local _key="$1" _value="$2" _conf="/etc/sysctl.conf"
	if grep -q "^${_key}=" "$_conf" 2>/dev/null; then
		sed -i "s|^${_key}=.*|${_key}=${_value}|" "$_conf" 2>/dev/null
	else
		printf '%s=%s\n' "$_key" "$_value" >> "$_conf" 2>/dev/null
	fi
}

# --- BSD: Hardware ---

kernel::bsd::hw::model() {
	sysctl -n hw.model 2>/dev/null || echo "unknown"
}

kernel::bsd::hw::machine() {
	sysctl -n hw.machine 2>/dev/null || echo "unknown"
}

kernel::bsd::hw::ncpu() {
	sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
}

kernel::bsd::hw::physmem() {
	sysctl -n hw.physmem 2>/dev/null || echo "unknown"
}

kernel::bsd::hw::pagesize() {
	sysctl -n hw.pagesize 2>/dev/null || echo "unknown"
}

kernel::bsd::hw::clockrate() {
	sysctl -n hw.clockrate 2>/dev/null || sysctl -n hw.cpuspeed 2>/dev/null || echo "unknown"
}

# --- BSD: Kernel Tunables ---

kernel::bsd::kern::maxproc::get() {
	sysctl -n kern.maxproc 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::maxproc::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::maxproc::set_session: requires root" >&2; return 1; }
	sysctl kern.maxproc="$1" 2>/dev/null
}

kernel::bsd::kern::maxproc::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::maxproc::set_system: requires root" >&2; return 1; }
	sysctl kern.maxproc="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.maxproc" "$1"
}

kernel::bsd::kern::maxfiles::get() {
	sysctl -n kern.maxfiles 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::maxfiles::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::maxfiles::set_session: requires root" >&2; return 1; }
	sysctl kern.maxfiles="$1" 2>/dev/null
}

kernel::bsd::kern::maxfiles::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::maxfiles::set_system: requires root" >&2; return 1; }
	sysctl kern.maxfiles="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.maxfiles" "$1"
}

kernel::bsd::kern::maxusers::get() {
	sysctl -n kern.maxusers 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::maxusers::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::maxusers::set_session: requires root" >&2; return 1; }
	sysctl kern.maxusers="$1" 2>/dev/null
}

kernel::bsd::kern::maxusers::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::maxusers::set_system: requires root" >&2; return 1; }
	sysctl kern.maxusers="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.maxusers" "$1"
}

kernel::bsd::kern::maxvnodes::get() {
	sysctl -n kern.maxvnodes 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::maxvnodes::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::maxvnodes::set_session: requires root" >&2; return 1; }
	sysctl kern.maxvnodes="$1" 2>/dev/null
}

kernel::bsd::kern::maxvnodes::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::maxvnodes::set_system: requires root" >&2; return 1; }
	sysctl kern.maxvnodes="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.maxvnodes" "$1"
}

kernel::bsd::kern::ipc::somaxconn::get() {
	sysctl -n kern.ipc.somaxconn 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::ipc::somaxconn::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::somaxconn::set_session: requires root" >&2; return 1; }
	sysctl kern.ipc.somaxconn="$1" 2>/dev/null
}

kernel::bsd::kern::ipc::somaxconn::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::somaxconn::set_system: requires root" >&2; return 1; }
	sysctl kern.ipc.somaxconn="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.ipc.somaxconn" "$1"
}

kernel::bsd::kern::ipc::maxsockbuf::get() {
	sysctl -n kern.ipc.maxsockbuf 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::ipc::maxsockbuf::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::maxsockbuf::set_session: requires root" >&2; return 1; }
	sysctl kern.ipc.maxsockbuf="$1" 2>/dev/null
}

kernel::bsd::kern::ipc::maxsockbuf::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::maxsockbuf::set_system: requires root" >&2; return 1; }
	sysctl kern.ipc.maxsockbuf="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.ipc.maxsockbuf" "$1"
}

kernel::bsd::kern::ipc::shmmax::get() {
	sysctl -n kern.ipc.shmmax 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::ipc::shmmax::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::shmmax::set_session: requires root" >&2; return 1; }
	sysctl kern.ipc.shmmax="$1" 2>/dev/null
}

kernel::bsd::kern::ipc::shmmax::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::shmmax::set_system: requires root" >&2; return 1; }
	sysctl kern.ipc.shmmax="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.ipc.shmmax" "$1"
}

kernel::bsd::kern::ipc::semmns::get() {
	sysctl -n kern.ipc.semmns 2>/dev/null || echo "unknown"
}

kernel::bsd::kern::ipc::semmns::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::semmns::set_session: requires root" >&2; return 1; }
	sysctl kern.ipc.semmns="$1" 2>/dev/null
}

kernel::bsd::kern::ipc::semmns::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::semmns::set_system: requires root" >&2; return 1; }
	sysctl kern.ipc.semmns="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.ipc.semmns" "$1"
}

# --- BSD: VM ---

kernel::bsd::vm::free_target::get() {
	sysctl -n vm.v_free_target 2>/dev/null || echo "unknown"
}

kernel::bsd::vm::free_target::set_session() {
	runtime::is_root || { echo "kernel::bsd::vm::free_target::set_session: requires root" >&2; return 1; }
	sysctl vm.v_free_target="$1" 2>/dev/null
}

kernel::bsd::vm::free_target::set_system() {
	runtime::is_root || { echo "kernel::bsd::vm::free_target::set_system: requires root" >&2; return 1; }
	sysctl vm.v_free_target="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "vm.v_free_target" "$1"
}

kernel::bsd::vm::cache_min::get() {
	sysctl -n vm.v_cache_min 2>/dev/null || echo "unknown"
}

kernel::bsd::vm::cache_min::set_session() {
	runtime::is_root || { echo "kernel::bsd::vm::cache_min::set_session: requires root" >&2; return 1; }
	sysctl vm.v_cache_min="$1" 2>/dev/null
}

kernel::bsd::vm::cache_min::set_system() {
	runtime::is_root || { echo "kernel::bsd::vm::cache_min::set_system: requires root" >&2; return 1; }
	sysctl vm.v_cache_min="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "vm.v_cache_min" "$1"
}

kernel::bsd::vm::free_reserved::get() {
	sysctl -n vm.v_free_reserved 2>/dev/null || echo "unknown"
}

kernel::bsd::vm::free_reserved::set_session() {
	runtime::is_root || { echo "kernel::bsd::vm::free_reserved::set_session: requires root" >&2; return 1; }
	sysctl vm.v_free_reserved="$1" 2>/dev/null
}

kernel::bsd::vm::free_reserved::set_system() {
	runtime::is_root || { echo "kernel::bsd::vm::free_reserved::set_system: requires root" >&2; return 1; }
	sysctl vm.v_free_reserved="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "vm.v_free_reserved" "$1"
}

kernel::bsd::vm::swapusage() {
	sysctl -n vm.swapusage 2>/dev/null || echo "unknown"
}

# --- BSD: Scheduler ---

kernel::bsd::sched::topology() {
	sysctl -n kern.sched.topology_spec 2>/dev/null || echo "unknown"
}

kernel::bsd::sched::timeslice::get() {
	sysctl -n kern.sched.timeslice 2>/dev/null || echo "unknown"
}

kernel::bsd::sched::timeslice::set_session() {
	runtime::is_root || { echo "kernel::bsd::sched::timeslice::set_session: requires root" >&2; return 1; }
	sysctl kern.sched.timeslice="$1" 2>/dev/null
}

kernel::bsd::sched::timeslice::set_system() {
	runtime::is_root || { echo "kernel::bsd::sched::timeslice::set_system: requires root" >&2; return 1; }
	sysctl kern.sched.timeslice="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.sched.timeslice" "$1"
}

# --- BSD: Security ---

kernel::bsd::security::unprivileged_proc_debug::get() {
	sysctl -n security.bsd.unprivileged_proc_debug 2>/dev/null || echo "unknown"
}

kernel::bsd::security::unprivileged_proc_debug::set_session() {
	runtime::is_root || { echo "kernel::bsd::security::unprivileged_proc_debug::set_session: requires root" >&2; return 1; }
	sysctl security.bsd.unprivileged_proc_debug="$1" 2>/dev/null
}

kernel::bsd::security::unprivileged_proc_debug::set_system() {
	runtime::is_root || { echo "kernel::bsd::security::unprivileged_proc_debug::set_system: requires root" >&2; return 1; }
	sysctl security.bsd.unprivileged_proc_debug="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "security.bsd.unprivileged_proc_debug" "$1"
}

kernel::bsd::security::see_other_uids::get() {
	sysctl -n security.bsd.see_other_uids 2>/dev/null || echo "unknown"
}

kernel::bsd::security::see_other_uids::set_session() {
	runtime::is_root || { echo "kernel::bsd::security::see_other_uids::set_session: requires root" >&2; return 1; }
	sysctl security.bsd.see_other_uids="$1" 2>/dev/null
}

kernel::bsd::security::see_other_uids::set_system() {
	runtime::is_root || { echo "kernel::bsd::security::see_other_uids::set_system: requires root" >&2; return 1; }
	sysctl security.bsd.see_other_uids="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "security.bsd.see_other_uids" "$1"
}

kernel::bsd::security::hardlink_uid_match::get() {
	sysctl -n security.bsd.hardlink_check_uid 2>/dev/null || echo "unknown"
}

kernel::bsd::security::hardlink_uid_match::set_session() {
	runtime::is_root || { echo "kernel::bsd::security::hardlink_uid_match::set_session: requires root" >&2; return 1; }
	sysctl security.bsd.hardlink_check_uid="$1" 2>/dev/null
}

kernel::bsd::security::hardlink_uid_match::set_system() {
	runtime::is_root || { echo "kernel::bsd::security::hardlink_uid_match::set_system: requires root" >&2; return 1; }
	sysctl security.bsd.hardlink_check_uid="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "security.bsd.hardlink_check_uid" "$1"
}

kernel::bsd::security::symlink_uid_match::get() {
	sysctl -n security.bsd.hardlink_check_same_uid 2>/dev/null || echo "unknown"
}

kernel::bsd::security::symlink_uid_match::set_session() {
	runtime::is_root || { echo "kernel::bsd::security::symlink_uid_match::set_session: requires root" >&2; return 1; }
	sysctl security.bsd.hardlink_check_same_uid="$1" 2>/dev/null
}

kernel::bsd::security::symlink_uid_match::set_system() {
	runtime::is_root || { echo "kernel::bsd::security::symlink_uid_match::set_system: requires root" >&2; return 1; }
	sysctl security.bsd.hardlink_check_same_uid="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "security.bsd.hardlink_check_same_uid" "$1"
}

# --- BSD: Summary ---

kernel::bsd::summary() {
	local _model _ncpu _physmem _maxproc _maxfiles _swap
	_model=$(kernel::bsd::hw::model)
	_ncpu=$(kernel::bsd::hw::ncpu)
	_physmem=$(kernel::bsd::hw::physmem)
	_maxproc=$(kernel::bsd::kern::maxproc::get)
	_maxfiles=$(kernel::bsd::kern::maxfiles::get)
	_swap=$(kernel::bsd::vm::swapusage)
	printf 'model=%s ncpu=%s physmem=%s maxproc=%s maxfiles=%s swap=%s\n' \
		"$_model" "$_ncpu" "$_physmem" "$_maxproc" "$_maxfiles" "$_swap"
}

# --- XNU (macOS/Darwin) ---

_kernel::xnu::persist_sysctl() {
	local _key="$1" _value="$2" _conf="/etc/sysctl.conf"
	if grep -q "^${_key}=" "$_conf" 2>/dev/null; then
		sed -i '' "s|^${_key}=.*|${_key}=${_value}|" "$_conf" 2>/dev/null
	else
		printf '%s=%s\n' "$_key" "$_value" >> "$_conf" 2>/dev/null
	fi
}

# --- XNU: Hardware ---

kernel::xnu::hw::model() {
	sysctl -n hw.model 2>/dev/null || echo "unknown"
}

kernel::xnu::hw::machine() {
	sysctl -n hw.machine 2>/dev/null || echo "unknown"
}

kernel::xnu::hw::ncpu() {
	sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
}

kernel::xnu::hw::memsize() {
	sysctl -n hw.memsize 2>/dev/null || echo "unknown"
}

kernel::xnu::hw::pagesize() {
	sysctl -n hw.pagesize 2>/dev/null || echo "unknown"
}

kernel::xnu::hw::cpufrequency() {
	sysctl -n hw.cpufrequency 2>/dev/null || echo "unknown"
}

kernel::xnu::hw::is_apple_silicon() {
	local _val
	_val=$(sysctl -n hw.optional.arm64 2>/dev/null) || { echo "0"; return 1; }
	echo "$_val"
}

kernel::xnu::hw::has_feature() {
	local _feature="$1"
	sysctl -n "hw.optional.${_feature}" 2>/dev/null || echo "0"
}

# --- XNU: Kernel ---

kernel::xnu::kern::osversion() {
	sysctl -n kern.osversion 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::uuid() {
	sysctl -n kern.uuid 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::bootuuid() {
	sysctl -n kern.bootuuid 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::bootsessionuuid() {
	sysctl -n kern.bootsessionuuid 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::sleeptype() {
	sysctl -n kern.sleeptype 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::wakereason() {
	sysctl -n kern.wakereason 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::maxproc::get() {
	sysctl -n kern.maxproc 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::maxproc::set_session() {
	runtime::is_root || { echo "kernel::xnu::kern::maxproc::set_session: requires root" >&2; return 1; }
	sysctl kern.maxproc="$1" 2>/dev/null
}

kernel::xnu::kern::maxproc::set_system() {
	runtime::is_root || { echo "kernel::xnu::kern::maxproc::set_system: requires root" >&2; return 1; }
	sysctl kern.maxproc="$1" 2>/dev/null || return 1
	_kernel::xnu::persist_sysctl "kern.maxproc" "$1"
}

kernel::xnu::kern::maxfiles::get() {
	sysctl -n kern.maxfiles 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::maxfiles::set_session() {
	runtime::is_root || { echo "kernel::xnu::kern::maxfiles::set_session: requires root" >&2; return 1; }
	sysctl kern.maxfiles="$1" 2>/dev/null
}

kernel::xnu::kern::maxfiles::set_system() {
	runtime::is_root || { echo "kernel::xnu::kern::maxfiles::set_system: requires root" >&2; return 1; }
	sysctl kern.maxfiles="$1" 2>/dev/null || return 1
	_kernel::xnu::persist_sysctl "kern.maxfiles" "$1"
}

kernel::xnu::kern::ipc::somaxconn::get() {
	sysctl -n kern.ipc.somaxconn 2>/dev/null || echo "unknown"
}

kernel::xnu::kern::ipc::somaxconn::set_session() {
	runtime::is_root || { echo "kernel::xnu::kern::ipc::somaxconn::set_session: requires root" >&2; return 1; }
	sysctl kern.ipc.somaxconn="$1" 2>/dev/null
}

kernel::xnu::kern::ipc::somaxconn::set_system() {
	runtime::is_root || { echo "kernel::xnu::kern::ipc::somaxconn::set_system: requires root" >&2; return 1; }
	sysctl kern.ipc.somaxconn="$1" 2>/dev/null || return 1
	_kernel::xnu::persist_sysctl "kern.ipc.somaxconn" "$1"
}

# --- XNU: macOS Version ---

kernel::xnu::swvers::product() {
	sw_vers -productName 2>/dev/null || echo "unknown"
}

kernel::xnu::swvers::version() {
	sw_vers -productVersion 2>/dev/null || echo "unknown"
}

kernel::xnu::swvers::build() {
	sw_vers -buildVersion 2>/dev/null || echo "unknown"
}

# --- XNU: VM ---

kernel::xnu::vm::stat() {
	vm_stat 2>/dev/null || echo "unknown"
}

kernel::xnu::vm::swapusage() {
	sysctl -n vm.swapusage 2>/dev/null || echo "unknown"
}

kernel::xnu::vm::compressor_mode() {
	sysctl -n vm.compressor_mode 2>/dev/null || echo "unknown"
}

kernel::xnu::vm::compressor_pages() {
	sysctl -n vm.compressor_pages_used 2>/dev/null || echo "unknown"
}

kernel::xnu::vm::pagefreeable() {
	sysctl -n vm.page_freeable 2>/dev/null || echo "unknown"
}

# --- XNU: SIP ---

kernel::xnu::sip::status() {
	csrutil status 2>&1 || echo "unknown"
}

kernel::xnu::sip::is_enabled() {
	local _status
	_status=$(csrutil status 2>&1) || return 1
	[[ "$_status" == *"enabled"* ]]
}

kernel::xnu::sip::enable() {
	local _result
	_result=$(csrutil enable 2>&1) || {
		echo "kernel::xnu::sip::enable: must be run from Recovery Mode" >&2
		echo "$_result" >&2
		return 1
	}
	echo "$_result"
}

kernel::xnu::sip::disable() {
	local _result
	_result=$(csrutil disable 2>&1) || {
		echo "kernel::xnu::sip::disable: must be run from Recovery Mode" >&2
		echo "$_result" >&2
		return 1
	}
	echo "$_result"
}

# --- XNU: Power ---

kernel::xnu::power::assertions() {
	pmset -g assertions 2>/dev/null || echo "unknown"
}

kernel::xnu::power::capacity() {
	pmset -g batt 2>/dev/null || echo "unknown"
}

kernel::xnu::power::thermals() {
	pmset -g therm 2>/dev/null || echo "unknown"
}

kernel::xnu::power::displaysleep::get() {
	local _val
	_val=$(pmset -g 2>/dev/null | awk '/ displaysleep/{print $2}')
	echo "${_val:-unknown}"
}

kernel::xnu::power::displaysleep::set_session() {
	runtime::is_root || { echo "kernel::xnu::power::displaysleep::set_session: requires root" >&2; return 1; }
	pmset displaysleep "$1" 2>/dev/null
}

kernel::xnu::power::displaysleep::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::displaysleep::set_system: requires root" >&2; return 1; }
	pmset -a displaysleep "$1" 2>/dev/null
}

kernel::xnu::power::sleep::get() {
	local _val
	_val=$(pmset -g 2>/dev/null | awk '/^ sleep/{print $2}')
	echo "${_val:-unknown}"
}

kernel::xnu::power::sleep::set_session() {
	runtime::is_root || { echo "kernel::xnu::power::sleep::set_session: requires root" >&2; return 1; }
	pmset sleep "$1" 2>/dev/null
}

kernel::xnu::power::sleep::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::sleep::set_system: requires root" >&2; return 1; }
	pmset -a sleep "$1" 2>/dev/null
}

kernel::xnu::power::disksleep::get() {
	local _val
	_val=$(pmset -g 2>/dev/null | awk '/ disksleep/{print $2}')
	echo "${_val:-unknown}"
}

kernel::xnu::power::disksleep::set_session() {
	runtime::is_root || { echo "kernel::xnu::power::disksleep::set_session: requires root" >&2; return 1; }
	pmset disksleep "$1" 2>/dev/null
}

kernel::xnu::power::disksleep::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::disksleep::set_system: requires root" >&2; return 1; }
	pmset -a disksleep "$1" 2>/dev/null
}

kernel::xnu::power::wakeonlan::get() {
	local _val
	_val=$(pmset -g 2>/dev/null | awk '/ WakeOnLan/{print $2}')
	echo "${_val:-unknown}"
}

kernel::xnu::power::wakeonlan::set_session() {
	runtime::is_root || { echo "kernel::xnu::power::wakeonlan::set_session: requires root" >&2; return 1; }
	pmset wakeonlan "$1" 2>/dev/null
}

kernel::xnu::power::wakeonlan::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::wakeonlan::set_system: requires root" >&2; return 1; }
	pmset -a wakeonlan "$1" 2>/dev/null
}

kernel::xnu::power::lidwake::get() {
	local _val
	_val=$(pmset -g 2>/dev/null | awk '/ LidWake/{print $2}')
	echo "${_val:-unknown}"
}

kernel::xnu::power::lidwake::set_session() {
	runtime::is_root || { echo "kernel::xnu::power::lidwake::set_session: requires root" >&2; return 1; }
	pmset lidwake "$1" 2>/dev/null
}

kernel::xnu::power::lidwake::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::lidwake::set_system: requires root" >&2; return 1; }
	pmset -a lidwake "$1" 2>/dev/null
}

# --- XNU: Summary ---

kernel::xnu::summary() {
	local _model _ncpu _memsize _osver _product _version _build
	_model=$(kernel::xnu::hw::model)
	_ncpu=$(kernel::xnu::hw::ncpu)
	_memsize=$(kernel::xnu::hw::memsize)
	_osver=$(kernel::xnu::kern::osversion)
	_product=$(kernel::xnu::swvers::product)
	_version=$(kernel::xnu::swvers::version)
	_build=$(kernel::xnu::swvers::build)
	printf 'model=%s ncpu=%s memsize=%s osver=%s product=%s version=%s build=%s\n' \
		"$_model" "$_ncpu" "$_memsize" "$_osver" "$_product" "$_version" "$_build"
}
