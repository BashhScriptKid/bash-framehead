# `pm::install`

**Signature:** `pm::install(package...)`

**Module:** [`pm`](../pm.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

!/usr/bin/env bash

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `package...` | string | — | |

## Source

```bash
pm::install() {
	local packages=("$@")
	local pm
	pm=$(runtime::pm)

	case "$pm" in
	apt) sudo apt-get install -y "${packages[@]}" ;;
	pacman) sudo pacman -S --noconfirm "${packages[@]}" ;;
	dnf) sudo dnf install -y "${packages[@]}" ;;
	yum) sudo yum install -y "${packages[@]}" ;;
	zypper) sudo zypper install -y "${packages[@]}" ;;
	apk) sudo apk add "${packages[@]}" ;;
	brew) brew install "${packages[@]}" ;;
	pkg) sudo pkg install -y "${packages[@]}" ;;
	xbps) sudo xbps-install -y "${packages[@]}" ;;
	nix) nix-env -iA "${packages[@]}" ;;
	*)
		echo "pm::install: unknown package manager" >&2
		return 1
		;;
	esac
}
```

