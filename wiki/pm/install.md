# `pm::install`

_No description available._

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

## Module

[`pm`](../pm.md)
