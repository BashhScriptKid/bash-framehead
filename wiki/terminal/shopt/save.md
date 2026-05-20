# `terminal::shopt::save`

Save current shopt state (prints a restore command)

## Usage

```bash
eval "$(terminal::shopt::save)"
```

## Source

```bash
terminal::shopt::save() {
    shopt | awk '$2 == "on"  {print "shopt -s " $1 ";"}'
    shopt | awk '$2 == "off" {print "shopt -u " $1 ";"}'
}
```

## Module

[`terminal`](../terminal.md)
