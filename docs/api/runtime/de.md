# `runtime::de`

**Signature:** `runtime::de()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::de() {
		if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
				echo "none"; return
		fi

		local _session="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-${GDMSESSION:-}}}"
		case "${_session,,}" in
				*gnome*)    echo "gnome";    return ;;
				*kde*)      echo "kde";      return ;;
				*xfce*)     echo "xfce";     return ;;
				*lxqt*)     echo "lxqt";     return ;;
				*lxde*)     echo "lxde";     return ;;
				*mate*)     echo "mate";     return ;;
				*cinnamon*) echo "cinnamon"; return ;;
				*budgie*)   echo "budgie";   return ;;
				*deepin*)   echo "deepin";   return ;;
				*pantheon*) echo "pantheon"; return ;;
				*unity*)    echo "unity";    return ;;
				*cosmic*)   echo "cosmic";   return ;;
		esac

		local -A _procs=(
				[gnome-shell]=gnome   [plasmashell]=kde      [xfce4-session]=xfce
				[lxqt-session]=lxqt   [lxsession]=lxde       [mate-session]=mate
				[cinnamon]=cinnamon   [budgie-daemon]=budgie  [deepin-session]=deepin
				[pantheon]=pantheon   [unity]=unity           [cosmic-session]=cosmic
		)
		local _p
		for _p in "${!_procs[@]}"; do
				pgrep -x "$_p" >/dev/null 2>&1 && echo "${_procs[$_p]}" && return
		done

		# Display present but only a bare WM — let caller query runtime::wm
		local _wm; _wm=$(runtime::wm)
		[[ "$_wm" != "unknown" ]] && echo "wm-only" && return

		echo "unknown"
}
```

