#!/bin/bash

# Directory to save the album cover
COVER_DIR="$HOME/.cache/awesome/spotify/media"
mkdir -p "$COVER_DIR"

# Fetch the cover URL using playerctl
COVER_URL=$(playerctl -p spotify metadata mpris:artUrl)

# Download the cover
curl -s -o "$COVER_DIR/cover.jpg" "$COVER_URL"

# Output the path to the cover
echo "$COVER_DIR/cover.jpg"
