#!/bin/sh -u

# 00doit-template.sh

# Prev updated: Wed Oct 27 06:38:35 JST 2021 by @hohno_at_kuimc
# Last updated: Tue Dec 14 06:39:57 JST 2021 by @hohno_at_kuimc

PNAME=$(basename $0)
# echo "$PNAME"

TARGET=$HOME/bin

opts="$opts"
opts="$opts --exclude=${PNAME}"
opts="$opts --exclude=.Spotlight-V100"
opts="$opts --exclude=.TemporaryItems"
opts="$opts --exclude=.fseventsd"
opts="$opts --exclude=.git*"
opts="$opts --exclude='*.swp'"
opts="$opts --exclude='*~'"
opts="$opts --exclude='*.bak'"

opts="$opts --exclude='*.md'"
opts="$opts --exclude='*.txt'"

echo $(echo rsync -avE $@ $opts $(pwd)/ $TARGET)
eval $(echo rsync -avE $@ $opts $(pwd)/ $TARGET)
