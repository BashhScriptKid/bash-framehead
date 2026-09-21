# `kernel::vmstat::summary`

**Signature:** `kernel::vmstat::summary()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
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
```

