#!/bin/bash

p=$1

/usr/bin/notify-send "Volume" -i /usr/share/notify-osd/icons/gnome/scalable/status/notification-message-im.svg -h int:value:${p} -h string:synchronous:volume
