# `process::tree`

**Signature:** `process::tree([pid])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get process tree from a PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | No | |

## Source

```bash
process::tree() {
		local pid="${1:-1}"
		if runtime::has_command pstree; then
				pstree -p "$pid"
		else
				ps -eo pid,ppid,comm | awk -v root="$pid" '
						NR==1{next}
						{parent[$1]=$2; name[$1]=$3}
						function show(p, indent,    c) {
								print indent p " " name[p]
								for (c in parent)
										if (parent[c]==p) show(c, indent "  ")
						}
						END{show(root, "")}
				'
		fi
}
```

