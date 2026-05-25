# `runtime::pm`

**Signature:** `runtime::pm()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::pm() {
	if runtime::has_command apt-get; then
		echo "apt"
	elif runtime::has_command pacman; then
		echo "pacman"
	elif runtime::has_command dnf; then
		echo "dnf"
	elif runtime::has_command yum; then
		echo "yum"
	elif runtime::has_command zypper; then
		echo "zypper"
	elif runtime::has_command apk; then
		echo "apk"
	elif runtime::has_command brew; then
		echo "brew"
	elif runtime::has_command pkg; then
		echo "pkg"
	elif runtime::has_command xbps-install; then
		echo "xbps"
	elif runtime::has_command nix-env; then
		echo "nix"
	else
		echo "unknown"
	fi
}
```

