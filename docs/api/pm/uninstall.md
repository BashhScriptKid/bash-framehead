# `pm::uninstall`

**Signature:** `pm::uninstall(package...)`

**Module:** [`pm`](../pm.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `package...` | string | — | |

## Source

```bash
pm::uninstall() {
	local packages=("$@")
	local pm
	pm=$(runtime::pm)

	case "$pm" in
	apt) sudo apt-get remove -y "${packages[@]}" ;;
	pacman) sudo pacman -R --noconfirm "${packages[@]}" ;;
	dnf) sudo dnf remove -y "${packages[@]}" ;;
	yum) sudo yum remove -y "${packages[@]}" ;;
	zypper) sudo zypper remove -y "${packages[@]}" ;;
	apk) sudo apk del "${packages[@]}" ;;
	brew) brew uninstall "${packages[@]}" ;;
	pkg) sudo pkg delete -y "${packages[@]}" ;;
	xbps) sudo xbps-remove -y "${packages[@]}" ;;
	nix) nix-env -e "${packages[@]}" ;;
	*)
		echo "pm::uninstall: unknown package manager" >&2
		return 1
		;;
	esac
}
```

