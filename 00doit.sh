#! /bin/sh

# 00doit.sh

# Last update: Wed Oct 27 06:38:35 JST 2021 by @hohno_at_kuimc

# ----------------------------------------------------------

PNAME=$(basename $0)
# echo "$PNAME"

TARGET="$HOME/tmp/xZone-test00"		# Never end with "/"
SOURCE="$(pwd)/xZone-test00"		# Never end with "/"

mesg_exit() {
  echo "$1"
  exit $2
}

usage_exit() {
  mesg_exit "usage: $PNAME [up|upload|down|download|unison|diff]" $1
}

[ "x$(which rsync)" = "x" ] && mesg_exit "${PNAME}: rsync is not installed. aborted..." 99
[ "x$(which unison)" = "x" ] && mesg_exit "${PNAME}: unison is not installed. aborted..." 99


# ----------------------------------------------------------

syncType="none"

if [ "x$1" = "x-h" -o "x$1" = "x--help" ]; then
  usage_exit 9
 :
elif [ "x$1" = "xup" -o "x$1" = "xupload" ]; then
  syncType="up"
  shift
  :
elif [ "x$1" = "xdown" -o "x$1" = "xdownload" ]; then
  syncType="down"
  shift
  :
elif [ "x$1" = "xunison" ]; then
  syncType="unison"
  shift
  :
elif [ "x$1" = "xdiff" ]; then
  syncType="diff"
  shift
  :
fi

if [ "x$syncType" = "xnone" ]; then
  usage_exit 1
  :
fi

if [ ! -d "$SOURCE" ]; then
  mesg_exit "${PNAME}: Can't find source directory ($SOURCE)" 1
  :
fi

if [ ! -d "$TARGET" ]; then
  mesg_exit "${PNAME}: Can't find target directory ($TARGET)" 1
  :
fi

# ----------------------------------------------------------

opts="$opts"
opts="$opts --exclude=${PNAME}"
opts="$opts --exclude=.Spotlight-V100"
opts="$opts --exclude=.TemporaryItems"
opts="$opts --exclude=.fseventsd"
opts="$opts --exclude=.git*"
opts="$opts --exclude='*.swp'"
opts="$opts --exclude='*~'"
opts="$opts --exclude='*.bak'"

# opts="$opts --exclude='*.md'"
# opts="$opts --exclude='*.txt'"

optx=$(echo $opts | sed -e 's/--exclude=/-ignore "Regex /g' -e 's/\(Regex [^ ]*\) /\1" /g' -e 's/$/"/')

# echo "($opts)"
# echo "($optx)"
# exit

# ----------------------------------------------------------

if [ "x$syncType" = "xup" ]; then
  echo "${PNAME}: ${SOURCE} -> ${TARGET}"
  # echo $(echo rsync -avE $@ $opts ${SOURCE}/ ${TARGET})
  eval $(echo rsync -avE $@ $opts ${SOURCE}/ ${TARGET})
  :
elif [ "x$syncType" = "xdown" ]; then
  echo "${PNAME}: ${TARGET} -> ${SOURCE}"
  # echo $(echo rsync -avE $@ $opts ${TARGET})/ ${SOURCE}
  eval $(echo rsync -avE $@ $opts ${TARGET})/ ${SOURCE}
  :
elif [ "x$syncType" = "xunison" ]; then
  echo "${PNAME}: ${TARGET} <-> ${SOURCE}"
  # echo $(echo "unison -auto $SOURCE $TARGET $optx")
  eval $(echo "unison -auto $SOURCE $TARGET $optx")
  :
elif [ "x$syncType" = "xdiff" ]; then
  echo "(diff)"
  echo $(echo diff -r -q ${SOURCE} ${TARGET})
  eval $(echo diff -r -q ${SOURCE} ${TARGET})
  echo "(unison)"
  unison -batch -noupdate "$SOURCE" -noupdate "$TARGET" "$SOURCE" "$TARGET"
  :
else
  usage_exit 2
  :
fi

exit 0
