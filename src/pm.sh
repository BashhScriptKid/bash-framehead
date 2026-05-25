#!/usr/bin/env bash
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

pm::sync() {
	local pm
	pm=$(runtime::pm)

	case "$pm" in
	apt) sudo apt-get update ;;
	pacman) sudo pacman -Sy ;;
	dnf) sudo dnf check-update ;;
	yum) sudo yum check-update ;;
	zypper) sudo zypper refresh ;;
	apk) sudo apk update ;;
	brew) brew update ;;
	pkg) sudo pkg update ;;
	xbps) sudo xbps-install -S ;;
	nix) nix-channel --update ;;
	*)
		echo "pm::sync: unknown package manager" >&2
		return 1
		;;
	esac
}

pm::update() {
	local pm
	pm=$(runtime::pm)

	case "$pm" in
	apt) sudo apt-get upgrade -y ;;
	pacman) sudo pacman -Su --noconfirm ;;
	dnf) sudo dnf upgrade -y ;;
	yum) sudo yum update -y ;;
	zypper) sudo zypper update -y ;;
	apk) sudo apk upgrade ;;
	brew) brew upgrade ;;
	pkg) sudo pkg upgrade -y ;;
	xbps) sudo xbps-install -u ;;
	nix) nix-env -u ;;
	*)
		echo "pm::update: unknown package manager" >&2
		return 1
		;;
	esac
}

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
