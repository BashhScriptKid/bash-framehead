# `pm::sync`

_No description available._

## Source

```bash
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
```

## Module

[`pm`](../pm.md)
