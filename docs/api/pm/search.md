# `pm::search`

**Signature:** `pm::search(query)`

**Module:** [`pm`](../pm.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `query` | string | Yes | |

## Source

```bash
pm::search() {
	local query="$1"
	local pm
	pm=$(runtime::pm)

	case "$pm" in
	apt) apt-cache search "$query" ;;
	pacman) pacman -Ss "$query" ;;
	dnf) dnf search "$query" ;;
	yum) yum search "$query" ;;
	zypper) zypper search "$query" ;;
	apk) apk search "$query" ;;
	brew) brew search "$query" ;;
	pkg) pkg search "$query" ;;
	xbps) xbps-query -Rs "$query" ;;
	nix) nix-env -qaP "$query" ;;
	*)
		echo "pm::search: unknown package manager" >&2
		return 1
		;;
	esac
}
```

