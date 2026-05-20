# `math::unitconvert`


**math:** :unitconvert — universal unit conversion dispatcher


## Usage

```bash
math::unitconvert from to value [scale]
```

## Example

```bash
math::unitconvert km mi 100
math::unitconvert femtosecond nanosecond 1000
math::unitconvert b gib 1073741824
```

## Source

```bash
math::unitconvert() {
    local from="${1,,}" to="${2,,}" value="$3" scale="${4:-$MATH_SCALE}"

    [[ -z "$from" || -z "$to" || -z "$value" ]] && {
        echo "Usage: math::unitconvert <from> <to> <value> [scale]" >&2
        return 1
    }

    # Normalise verbose/alternative names to canonical short keys
    local -A _n=(
        # Temperature
        [celsius]="celsius"   [centigrade]="celsius"
        [fahrenheit]="fahrenheit"
        [kelvin]="kelvin"

        # Length
        [femtometre]="fm"     [femtometer]="fm"   [femtometres]="fm"  [femtometers]="fm"
        [picometre]="pm"      [picometer]="pm"    [picometres]="pm"   [picometers]="pm"
        [nanometre_si]="nm_si" [nanometer_si]="nm_si"
        [micrometre]="um"     [micrometer]="um"   [micrometres]="um"  [micrometers]="um"   [um]="um"
        [millimetre]="mm"     [millimeter]="mm"   [millimetres]="mm"  [millimeters]="mm"   [mm]="mm"
        [centimetre]="cm"     [centimeter]="cm"   [centimetres]="cm"  [centimeters]="cm"   [cm]="cm"
        [metre]="m"           [meter]="m"         [metres]="m"        [meters]="m"
        [kilometre]="km"      [kilometer]="km"    [kilometres]="km"   [kilometers]="km"    [km]="km"
        [inch]="in"           [inches]="in"
        [foot]="ft"           [feet]="ft"
        [yard]="yd"           [yards]="yd"
        [mile]="mi"           [miles]="mi"
        [nautical_mile]="nm"  [nautical_miles]="nm"
        [astronomical_unit]="au" [astronomical_units]="au"
        [light_year]="ly"     [lightyear]="ly"    [light_years]="ly"  [lightyears]="ly"
        [light_hour]="lh"     [lighthour]="lh"    [light_hours]="lh"  [lighthours]="lh"
        [light_day]="ld"      [lightday]="ld"     [light_days]="ld"   [lightdays]="ld"
        [parsec]="pc"         [parsecs]="pc"

        # Mass
        [microgram]="ug"      [micrograms]="ug"
        [milligram]="mg"      [milligrams]="mg"   [mg]="mg"
        [gram]="g"            [grams]="g"
        [kilogram]="kg"       [kilograms]="kg"    [kg]="kg"
        [tonne]="t"           [metric_ton]="t"    [metric_tons]="t"
        [ounce]="oz"          [ounces]="oz"
        [pound]="lb"          [pounds]="lb"       [lbs]="lb"
        [stone]="st"          [stones]="st"

        # Volume
        [millilitre]="ml"     [milliliter]="ml"   [millilitres]="ml"  [milliliters]="ml"   [ml]="ml"
        [litre]="l"           [liter]="l"         [litres]="l"        [liters]="l"
        [cubic_metre]="m3"    [cubic_meter]="m3"
        [teaspoon]="tsp"      [teaspoons]="tsp"
        [tablespoon]="tbsp"   [tablespoons]="tbsp"
        [fluid_ounce]="floz"  [fluid_ounces]="floz"
        [pint]="pt"           [pints]="pt"
        [quart]="qt"          [quarts]="qt"
        [gallon]="gal"        [gallons]="gal"

        # Speed
        [kph]="kmh"           [km_h]="kmh"        [kilometres_per_hour]="kmh" [kilometers_per_hour]="kmh"
        [mph]="mph"           [miles_per_hour]="mph"
        [m_s]="ms"            [metres_per_second]="ms" [meters_per_second]="ms"
        [knot]="knot"         [knots]="knot"
        [mach]="mach"
        [speed_of_light]="c"

        # Pressure
        [pascal]="pa"         [pascals]="pa"
        [kilopascal]="kpa"    [kilopascals]="kpa"
        [bar]="bar"           [bars]="bar"
        [atmosphere]="atm"    [atmospheres]="atm"
        [pounds_per_square_inch]="psi"
        [millimetre_of_mercury]="mmhg" [millimeter_of_mercury]="mmhg" [torr]="mmhg"

        # Energy
        [joule]="j"           [joules]="j"
        [kilojoule]="kj"      [kilojoules]="kj"
        [calorie]="cal"       [calories]="cal"
        [kilocalorie]="kcal"  [kilocalories]="kcal"
        [kilowatt_hour]="kwh" [kilowatt_hours]="kwh"
        [electronvolt]="ev"   [electronvolts]="ev"
        [british_thermal_unit]="btu" [british_thermal_units]="btu"

        # Power
        [watt]="w"            [watts]="w"
        [kilowatt]="kw"       [kilowatts]="kw"
        [horsepower]="hp"

        # Digital storage
        [bit]="b"             [bits]="b"
        [kilobit]="kb"        [kilobits]="kb"
        [megabit]="mb"        [megabits]="mb"
        [gigabit]="gb"        [gigabits]="gb"
        [terabit]="tb"        [terabits]="tb"
        [petabit]="pb"        [petabits]="pb"
        [kibibit]="kib"       [kibibits]="kib"
        [mebibit]="mib"       [mebibits]="mib"
        [gibibit]="gib"       [gibibits]="gib"
        [tebibit]="tib"       [tebibits]="tib"
        [pebibit]="pib"       [pebibits]="pib"
        [sector]="sector"     [sectors]="sector"  [512b]="sector"
        [sector4k]="sector4k" [4k_sector]="sector4k" [advanced_format]="sector4k"

        # Time
        [femtosecond]="fs"    [femtoseconds]="fs"
        [picosecond]="ps"     [picoseconds]="ps"
        [nanosecond]="ns"     [nanoseconds]="ns"  [ns]="ns"
        [microsecond]="us"    [microseconds]="us" [us]="us"
        [millisecond]="ms"    [milliseconds]="ms" [ms]="ms"
        [second]="s"          [seconds]="s"       [sec]="s"
        [minute]="min"        [minutes]="min"
        [hour]="h"            [hours]="h"         [hr]="h"
        [day]="d"             [days]="d"
        [week]="week"         [weeks]="week"
        [year]="year"         [years]="year"      [yr]="year"

        # Angle
        [degree]="deg"        [degrees]="deg"
        [radian]="rad"        [radians]="rad"
        [gradian]="grad"      [gradians]="grad"   [gon]="grad"
        [arcminute]="arcmin"  [arcminutes]="arcmin"
        [arcsecond]="arcsec"  [arcseconds]="arcsec"
    )

    # Apply normalisation — fall back to original if not in table
    [[ -n "${_n[$from]+x}" ]] && from="${_n[$from]}"
    [[ -n "${_n[$to]+x}"   ]] && to="${_n[$to]}"

    [[ "$from" == "$to" ]] && echo "$value" && return 0

    local key="${from}:${to}"
    local expr

    case "$key" in

    # --- Temperature ---
    celsius:fahrenheit  | c:f)    expr="$value * 9/5 + 32" ;;
    fahrenheit:celsius  | f:c)    expr="($value - 32) * 5/9" ;;
    celsius:kelvin      | c:k)    expr="$value + 273.15" ;;
    kelvin:celsius      | k:c)    expr="$value - 273.15" ;;
    fahrenheit:kelvin   | f:k)    expr="($value - 32) * 5/9 + 273.15" ;;
    kelvin:fahrenheit   | k:f)    expr="($value - 273.15) * 9/5 + 32" ;;

    # --- Length ---
    km:mi)              expr="$value * 0.621371" ;;
    mi:km)              expr="$value * 1.609344" ;;
    m:ft)               expr="$value * 3.28084" ;;
    ft:m)               expr="$value * 0.3048" ;;
    cm:in)              expr="$value * 0.393701" ;;
    in:cm)              expr="$value * 2.54" ;;
    m:yd)               expr="$value * 1.09361" ;;
    yd:m)               expr="$value * 0.9144" ;;
    mm:in)              expr="$value * 0.0393701" ;;
    in:mm)              expr="$value * 25.4" ;;
    m:km)               expr="$value / 1000" ;;
    km:m)               expr="$value * 1000" ;;
    cm:m)               expr="$value / 100" ;;
    m:cm)               expr="$value * 100" ;;
    mm:m)               expr="$value / 1000" ;;
    m:mm)               expr="$value * 1000" ;;
    cm:mm)              expr="$value * 10" ;;
    mm:cm)              expr="$value / 10" ;;
    nm_si:m)            expr="$value / 1000000000" ;;
    m:nm_si)            expr="$value * 1000000000" ;;
    pm:m)               expr="$value / 1000000000000" ;;
    m:pm)               expr="$value * 1000000000000" ;;
    fm:m)               expr="$value / 1000000000000000" ;;
    m:fm)               expr="$value * 1000000000000000" ;;
    fm:pm)              expr="$value / 1000" ;;
    pm:fm)              expr="$value * 1000" ;;
    nm_si:pm)           expr="$value * 1000" ;;
    pm:nm_si)           expr="$value / 1000" ;;
    nm_si:fm)           expr="$value * 1000000" ;;
    fm:nm_si)           expr="$value / 1000000" ;;
    nm:km)              expr="$value * 1.852" ;;
    km:nm)              expr="$value / 1.852" ;;
    ly:km)              expr="$value * 9460730472580.8" ;;
    km:ly)              expr="$value / 9460730472580.8" ;;
    lh:km)              expr="$value * 1079251200" ;;
    km:lh)              expr="$value / 1079251200" ;;
    ld:km)              expr="$value * 25902068371.2" ;;
    km:ld)              expr="$value / 25902068371.2" ;;
    lh:ly)              expr="$value / 8765.81" ;;
    ly:lh)              expr="$value * 8765.81" ;;
    ld:ly)              expr="$value / 365.25" ;;
    ly:ld)              expr="$value * 365.25" ;;
    ld:lh)              expr="$value * 24" ;;
    lh:ld)              expr="$value / 24" ;;
    au:km)              expr="$value * 149597870.7" ;;
    km:au)              expr="$value / 149597870.7" ;;
    pc:ly)              expr="$value * 3.26156" ;;
    ly:pc)              expr="$value / 3.26156" ;;
    pc:km)              expr="$value * 30856775814913.7" ;;
    km:pc)              expr="$value / 30856775814913.7" ;;

    # --- Mass ---
    kg:lb)              expr="$value * 2.20462" ;;
    lb:kg)              expr="$value * 0.453592" ;;
    g:oz)               expr="$value * 0.035274" ;;
    oz:g)               expr="$value * 28.3495" ;;
    g:kg)               expr="$value / 1000" ;;
    kg:g)               expr="$value * 1000" ;;
    mg:g)               expr="$value / 1000" ;;
    g:mg)               expr="$value * 1000" ;;
    t:kg)               expr="$value * 1000" ;;
    kg:t)               expr="$value / 1000" ;;
    t:lb)               expr="$value * 2204.62" ;;
    lb:t)               expr="$value / 2204.62" ;;
    st:kg)              expr="$value * 6.35029" ;;
    kg:st)              expr="$value / 6.35029" ;;

    # --- Volume ---
    l:gal)              expr="$value * 0.264172" ;;
    gal:l)              expr="$value * 3.78541" ;;
    ml:floz)            expr="$value * 0.033814" ;;
    floz:ml)            expr="$value * 29.5735" ;;
    l:pt)               expr="$value * 2.11338" ;;
    pt:l)               expr="$value / 2.11338" ;;
    ml:l)               expr="$value / 1000" ;;
    l:ml)               expr="$value * 1000" ;;
    l:qt)               expr="$value * 1.05669" ;;
    qt:l)               expr="$value / 1.05669" ;;
    m3:l)               expr="$value * 1000" ;;
    l:m3)               expr="$value / 1000" ;;
    tsp:ml)             expr="$value * 4.92892" ;;
    ml:tsp)             expr="$value / 4.92892" ;;
    tbsp:ml)            expr="$value * 14.7868" ;;
    ml:tbsp)            expr="$value / 14.7868" ;;

    # --- Speed ---
    kmh:mph)            expr="$value * 0.621371" ;;
    mph:kmh)            expr="$value * 1.609344" ;;
    ms:kmh)             expr="$value * 3.6" ;;
    kmh:ms)             expr="$value / 3.6" ;;
    ms:mph)             expr="$value * 2.23694" ;;
    mph:ms)             expr="$value / 2.23694" ;;
    knot:kmh)           expr="$value * 1.852" ;;
    kmh:knot)           expr="$value / 1.852" ;;
    knot:mph)           expr="$value * 1.15078" ;;
    mph:knot)           expr="$value / 1.15078" ;;
    mach:ms)            expr="$value * 343" ;;
    ms:mach)            expr="$value / 343" ;;
    c:ms)               expr="299792458" ;;

    # --- Pressure ---
    pa:psi)             expr="$value * 0.000145038" ;;
    psi:pa)             expr="$value * 6894.76" ;;
    atm:pa)             expr="$value * 101325" ;;
    pa:atm)             expr="$value / 101325" ;;
    bar:pa)             expr="$value * 100000" ;;
    pa:bar)             expr="$value / 100000" ;;
    atm:bar)            expr="$value * 1.01325" ;;
    bar:atm)            expr="$value / 1.01325" ;;
    mmhg:pa)            expr="$value * 133.322" ;;
    pa:mmhg)            expr="$value / 133.322" ;;

    # --- Energy ---
    j:cal)              expr="$value * 0.239006" ;;
    cal:j)              expr="$value * 4.18400" ;;
    j:kwh)              expr="$value / 3600000" ;;
    kwh:j)              expr="$value * 3600000" ;;
    j:btu)              expr="$value * 0.000947817" ;;
    btu:j)              expr="$value / 0.000947817" ;;
    ev:j)               expr="$value * 0.0000000000000000001602176634" ;;
    j:ev)               expr="$value / 0.0000000000000000001602176634" ;;
    kcal:j)             expr="$value * 4184" ;;
    j:kcal)             expr="$value / 4184" ;;

    # --- Power ---
    w:hp)               expr="$value * 0.00134102" ;;
    hp:w)               expr="$value / 0.00134102" ;;
    w:kw)               expr="$value / 1000" ;;
    kw:w)               expr="$value * 1000" ;;
    kw:hp)              expr="$value * 1.34102" ;;
    hp:kw)              expr="$value / 1.34102" ;;

    # --- Digital storage ---
    b:kb)               expr="$value / 1000" ;;
    kb:b)               expr="$value * 1000" ;;
    b:mb)               expr="$value / 1000000" ;;
    mb:b)               expr="$value * 1000000" ;;
    b:gb)               expr="$value / 1000000000" ;;
    gb:b)               expr="$value * 1000000000" ;;
    b:tb)               expr="$value / 1000000000000" ;;
    tb:b)               expr="$value * 1000000000000" ;;
    kb:mb)              expr="$value / 1000" ;;
    mb:kb)              expr="$value * 1000" ;;
    mb:gb)              expr="$value / 1000" ;;
    gb:mb)              expr="$value * 1000" ;;
    gb:tb)              expr="$value / 1000" ;;
    tb:gb)              expr="$value * 1000" ;;
    tb:pb)              expr="$value / 1000" ;;
    pb:tb)              expr="$value * 1000" ;;
    b:kib)              expr="$value / 1024" ;;
    kib:b)              expr="$value * 1024" ;;
    b:mib)              expr="$value / 1048576" ;;
    mib:b)              expr="$value * 1048576" ;;
    b:gib)              expr="$value / 1073741824" ;;
    gib:b)              expr="$value * 1073741824" ;;
    b:tib)              expr="$value / 1099511627776" ;;
    tib:b)              expr="$value * 1099511627776" ;;
    kib:mib)            expr="$value / 1024" ;;
    mib:kib)            expr="$value * 1024" ;;
    mib:gib)            expr="$value / 1024" ;;
    gib:mib)            expr="$value * 1024" ;;
    gib:tib)            expr="$value / 1024" ;;
    tib:gib)            expr="$value * 1024" ;;
    tib:pib)            expr="$value / 1024" ;;
    pib:tib)            expr="$value * 1024" ;;
    sector:b)           expr="$value * 512" ;;
    b:sector)           expr="$value / 512" ;;
    sector:kb)          expr="$value / 2" ;;
    kb:sector)          expr="$value * 2" ;;
    sector:mb)          expr="$value / 2000" ;;
    mb:sector)          expr="$value * 2000" ;;
    sector:gb)          expr="$value / 2000000" ;;
    gb:sector)          expr="$value * 2000000" ;;
    sector:kib)         expr="$value / 2" ;;
    kib:sector)         expr="$value * 2" ;;
    sector:mib)         expr="$value / 2048" ;;
    mib:sector)         expr="$value * 2048" ;;
    sector:gib)         expr="$value / 2097152" ;;
    gib:sector)         expr="$value * 2097152" ;;
    sector4k:b)         expr="$value * 4096" ;;
    b:sector4k)         expr="$value / 4096" ;;
    sector4k:kib)       expr="$value * 4" ;;
    kib:sector4k)       expr="$value / 4" ;;
    sector4k:mib)       expr="$value / 256" ;;
    mib:sector4k)       expr="$value * 256" ;;
    sector4k:gib)       expr="$value / 262144" ;;
    gib:sector4k)       expr="$value * 262144" ;;
    sector:sector4k)    expr="$value / 8" ;;
    sector4k:sector)    expr="$value * 8" ;;

    # --- Time ---
    s:ms)               expr="$value * 1000" ;;
    ms:s)               expr="$value / 1000" ;;
    s:us)               expr="$value * 1000000" ;;
    us:s)               expr="$value / 1000000" ;;
    s:ns)               expr="$value * 1000000000" ;;
    ns:s)               expr="$value / 1000000000" ;;
    s:ps)               expr="$value * 1000000000000" ;;
    ps:s)               expr="$value / 1000000000000" ;;
    s:fs)               expr="$value * 1000000000000000" ;;
    fs:s)               expr="$value / 1000000000000000" ;;
    ms:us)              expr="$value * 1000" ;;
    us:ms)              expr="$value / 1000" ;;
    us:ns)              expr="$value * 1000" ;;
    ns:us)              expr="$value / 1000" ;;
    ns:ps)              expr="$value * 1000" ;;
    ps:ns)              expr="$value / 1000" ;;
    ps:fs)              expr="$value * 1000" ;;
    fs:ps)              expr="$value / 1000" ;;
    fs:ns)              expr="$value / 1000000" ;;
    ns:fs)              expr="$value * 1000000" ;;
    fs:us)              expr="$value / 1000000000" ;;
    us:fs)              expr="$value * 1000000000" ;;
    fs:ms)              expr="$value / 1000000000000" ;;
    ms:fs)              expr="$value * 1000000000000" ;;
    s:min)              expr="$value / 60" ;;
    min:s)              expr="$value * 60" ;;
    min:ms)             expr="$value * 60000" ;;
    ms:min)             expr="$value / 60000" ;;
    min:h)              expr="$value / 60" ;;
    h:min)              expr="$value * 60" ;;
    h:s)                expr="$value * 3600" ;;
    s:h)                expr="$value / 3600" ;;
    h:d)                expr="$value / 24" ;;
    d:h)                expr="$value * 24" ;;
    d:s)                expr="$value * 86400" ;;
    s:d)                expr="$value / 86400" ;;
    d:week)             expr="$value / 7" ;;
    week:d)             expr="$value * 7" ;;
    d:year)             expr="$value / 365.25" ;;
    year:d)             expr="$value * 365.25" ;;

    # --- Angle ---
    deg:rad)            expr="$value * 3.141592653589793238462643383279502884197169 / 180" ;;
    rad:deg)            expr="$value * 180 / 3.141592653589793238462643383279502884197169" ;;
    deg:grad)           expr="$value * 400 / 360" ;;
    grad:deg)           expr="$value * 360 / 400" ;;
    rad:grad)           expr="$value * 200 / 3.141592653589793238462643383279502884197169" ;;
    grad:rad)           expr="$value * 3.141592653589793238462643383279502884197169 / 200" ;;
    deg:arcmin)         expr="$value * 60" ;;
    arcmin:deg)         expr="$value / 60" ;;
    deg:arcsec)         expr="$value * 3600" ;;
    arcsec:deg)         expr="$value / 3600" ;;
    arcmin:arcsec)      expr="$value * 60" ;;
    arcsec:arcmin)      expr="$value / 60" ;;

    *)
        echo "math::unitconvert: unknown conversion '${from}' → '${to}'" >&2
        return 1
        ;;
    esac

    math::bc "$expr" "$scale"
}
```

## Module

[`math`](../math.md)
