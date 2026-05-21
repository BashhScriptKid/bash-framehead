# `pm::update`

**Signature:** `pm::update()`

**Module:** [`pm`](../pm.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
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
```

