# `process::tree`

Get process tree from a PID

## Usage

```bash
process::tree [pid]
```

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

## Module

[`process`](../process.md)
