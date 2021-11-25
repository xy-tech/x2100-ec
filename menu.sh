#!/bin/sh
set -x
dialog --checklist          'Choose the desired patches' 0 0 0 \
    fix-ec-debug            'Allow hot-patching of EC.' on \
    lcd-brightness          'Allow lowering LCD backlight brightness to 1%' on \
    fn-swap                 'Swap Fn and Ctrl keys' off \
    lcd-backlight-925hz     'LCD backlight to 925Hz' off \
    true-battery-reading    'Fix battery reading above 70%' on \
    battery-current         'Fix battery current measurement' on \
    fast-charge             'Fast charge 6C and 9C batteries, and limit input power to 80W' off \
    fix-fan                 'Patch fan similarly as is done with x210' off \
    default-fan-pwm-table   'Set default fan pwm table' off \
    silent-fan-pwm-table    'Set silent fan pwm table' off \
    silent2-fan-pwm-table   'Set silent 2 fan pwm table' off \
    2> selected
for p in $(cat selected); do
    fn="patches/$p.rapatch"
    if [ ! -e "$fn" ]; then
        echo "The patch \"$fn\" doesn't exist!"
        exit 1
    fi
    r2 -w -q -P "$fn" ec.bin || true    # see https://github.com/radare/radare2/issues/15002
done
