#!/usr/bin/env bash
pm::install() {
    local pm
    pm=$(runtime::pm)

    case "$pm" in
    apt) sudo apt-get install -y "$@" ;;
    pacman) sudo pacman -S --noconfirm "$@" ;;
    dnf) sudo dnf install -y "$@" ;;
    yum) sudo yum install -y "$@" ;;
    zypper) sudo zypper install -y "$@" ;;
    apk) sudo apk add "$@" ;;
    brew) brew install "$@" ;;
    pkg) sudo pkg install -y "$@" ;;
    xbps) sudo xbps-install -y "$@" ;;
    nix) nix-env -iA "$@" ;;
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
    local pm
    pm=$(runtime::pm)

    case "$pm" in
    apt) sudo apt-get remove -y "$@" ;;
    pacman) sudo pacman -R --noconfirm "$@" ;;
    dnf) sudo dnf remove -y "$@" ;;
    yum) sudo yum remove -y "$@" ;;
    zypper) sudo zypper remove -y "$@" ;;
    apk) sudo apk del "$@" ;;
    brew) brew uninstall "$@" ;;
    pkg) sudo pkg delete -y "$@" ;;
    xbps) sudo xbps-remove -y "$@" ;;
    nix) nix-env -e "$@" ;;
    *)
        echo "pm::uninstall: unknown package manager" >&2
        return 1
        ;;
    esac
}

pm::search() {
    local pm
    pm=$(runtime::pm)

    case "$pm" in
    apt) apt-cache search "$1" ;;
    pacman) pacman -Ss "$1" ;;
    dnf) dnf search "$1" ;;
    yum) yum search "$1" ;;
    zypper) zypper search "$1" ;;
    apk) apk search "$1" ;;
    brew) brew search "$1" ;;
    pkg) pkg search "$1" ;;
    xbps) xbps-query -Rs "$1" ;;
    nix) nix-env -qaP "$1" ;;
    *)
        echo "pm::search: unknown package manager" >&2
        return 1
        ;;
    esac
}
