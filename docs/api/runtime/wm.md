# `runtime::wm`

**Signature:** `runtime::wm()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::wm() {
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
        echo "none"; return
    fi

    local _s="${XDG_SESSION_DESKTOP:-}"
    case "${_s,,}" in
        *hyprland*) echo "hyprland"; return ;;
        *sway*)     echo "sway";     return ;;
        *wayfire*)  echo "wayfire";  return ;;
        *river*)    echo "river";    return ;;
    esac

    if runtime::has_command xprop && [[ -n "${DISPLAY:-}" ]]; then
        local _n
        _n=$(xprop -root -notype _NET_WM_NAME 2>/dev/null | sed 's/.*= *"//;s/".*//')
        [[ -n "$_n" ]] && echo "${_n,,}" && return
    fi

    local -A _procs=(
        [hyprland]=hyprland      [sway]=sway          [wayfire]=wayfire
        [river]=river            [mutter]=mutter       [kwin_wayland]=kwin
        [kwin_x11]=kwin          [xfwm4]=xfwm4        [openbox]=openbox
        [i3]=i3                  [bspwm]=bspwm         [awesome]=awesome
        [herbstluftwm]=herbstluftwm                   [fluxbox]=fluxbox
        [icewm]=icewm            [jwm]=jwm             [qtile]=qtile
        [xmonad]=xmonad          [marco]=marco         [metacity]=metacity
        [compiz]=compiz          [enlightenment]=enlightenment
    )
    local _p
    for _p in "${!_procs[@]}"; do
        pgrep -x "$_p" >/dev/null 2>&1 && echo "${_procs[$_p]}" && return
    done

    echo "unknown"
}
```

