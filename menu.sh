#!/bin/sh
set -x
dialog --checklist 'Choose the desired patches' 0 0 0 \
	fix-ec-debug            'Allow hot-patching of EC.' on \
	lcd-brightness		'Allow lowering LCD backlight brightness to 1%' on \
	fn-swap			'Swap Fn and Ctrl keys (untested, but should work)' off \
	lcd-backlight-925hz     'LCD backlight to 925Hz (untested, but should work)' off \
	true-battery-reading	'Fix battery reading above 70% (experimental)' on \
	battery-current		'Fix battery current measurement (SUPER EXPERIMENTAL)' off \
	2> selected
for p in $(cat selected); do
	fn="patches/$p.rapatch"
	if [ ! -e "$fn" ]; then
		echo "The patch \"$fn\" doesn't exist!"
		exit 1
	fi
	r2 -w -q -P "$fn" ec.bin || true	# see https://github.com/radare/radare2/issues/15002
done
