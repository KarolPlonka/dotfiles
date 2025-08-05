#!/bin/bash

# Create temp file
tmpfile=$(mktemp)

# Open new terminal with nvim
gnome-terminal -- nvim "$tmpfile"
