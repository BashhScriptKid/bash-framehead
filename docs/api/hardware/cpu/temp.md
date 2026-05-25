# `hardware::cpu::temp`

**Signature:** `hardware::cpu::temp(arg1, arg2)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
hardware::cpu::temp() {
		case "$(runtime::os)" in
		linux|wsl)
				local temp_dir
				for dir in /sys/class/hwmon/*; do
						[[ -f "${dir}/name" ]] || continue
						if [[ "$(< "${dir}/name")" =~ (cpu_thermal|coretemp|fam15h_power|k10temp) ]]; then
								local inputs=("${dir}"/temp*_input)
								temp_dir="${inputs[0]}"
								break
						fi
				done
				if [[ -f "$temp_dir" ]]; then
						awk '{ printf "%.1f\n", $1/1000 }' "$temp_dir"
				else
						echo "unknown"
				fi
				;;
		darwin)
				# No native CLI — would need osx-cpu-temp or similar
				echo "unknown"
				;;
		freebsd|dragonfly)
				sysctl -n dev.cpu.0.temperature 2>/dev/null | tr -d 'C' || echo "unknown"
				;;
		openbsd|netbsd)
				sysctl hw.sensors 2>/dev/null | \
						awk -F'=|degC' '/(ksmn|adt|lm|cpu)0.temp0/ {printf("%.1f\n", $2); exit}' \
						|| echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

