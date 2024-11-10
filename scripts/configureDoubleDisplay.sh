#!/bin/bash
# Run xrandr to configure displays
xrandr --output HDMI-1 --mode 1920x1080 --rate 60 --primary --output eDP-1 --mode 1920x1080 --right-of HDMI-1

# Wait for xrandr to finish
# sleep 5

# Reapply wallpaper using Nitrogen
# nitrogen --restore
