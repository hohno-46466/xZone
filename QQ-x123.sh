#!/usr/bin/env bash
set -u

# 注意：
# このままでは動かない！
# 以下のコード中の TARGET, DIR1, DIR2 を適切に設定しておく必要がある
#
# ----------------------------------------------------------

# QQ-TEMPLATE.sh

# Prev update: Wed Oct 27 06:38:35 JST 2021 by @hohno_at_kuimc
# Prev update: Tue Nov 30 20:47:51 JST 2021 by @hohno_at_kuimc
# Prev update: Sun Mar 27 09:15:15 JST 2022 by @hohno_at_kuimc
# Prev update: 2026-03-14(Sat) 09:07 JST / 2026-03-14(Sat) 00:07 UTC
# Last update: 2026-03-14(Sat) 11:36 JST / 2026-03-14(Sat) 02:36 UTC supported by ChatGPT

# ----------------------------------------------------------

#
# ファイル名中に含まれている名前と同名のディレクトリが二箇所にある。
# これらのディレクトリに対し，作業中の場所によって挙動を変えながら
# rsync / unison / diff を使って同期・比較するためのスクリプト
#
# 使い方：
#   たとえば TARGET=foo DIR1="$HOME/GitHub" DIR2="$HOME/tmp"
#   ファイル名を QQ-foo.sh という名前にした場合：
#
# ・$DIR2 ($HOME/tmp) 側で bash ./QQ-foo.sh down を実行
#   （あるいは $DIR1 ($HOME/GitHub/foo) 側で bash ./QQ-foo.sh up を実行）
#   → $DIR1 (GitHubの foo/) から $DIR2 (tmp の foo/) へ向けて rsync でコピー
#
# ・$DIR2 ($HOME/tmp) 側で bash ./QQ-foo.sh up を実行
#   （あるいは $DIR1 ($HOME/GitHub/foo) 側で bash ./QQ-foo.sh down を実行）
#   → $DIR2 (tmp の foo/) から $DIR1 (GitHub の foo/ ) へ向けて rsync でコピー
#
#   *** 自分が現在いる側が下側でやりとりする相手が上側だと考えて up/down を判断するとよい ***
#
# ・どちら側にいても bash ./QQ-foo.sh unison を実行：
#   → unison コマンドを使った双方向同期
#
# ・どちら側でも bash ./QQ-foo.sh diff を実行：
#   → 差分確認
#

# ----------------------------------------------------------

PNAME=$(basename $0)
# echo "$PNAME"

# スクリプト名は QQ-${TARGET}.sh として保存し，この名前で実行する．
# Never end with "/"
TARGET="TEMPLATE"
TARGET="x123"

# DIR1 は適宜書き換えること
# Never end with "/"
# DIR1="$HOME/GitHub/TEMPLATE_DIR"
DIR1="$HOME/GitHub"

# DIR2 は適宜書き換えること
# Never end with "/"
DIR2="$HOME/tmp"

# ----------------------------------------------------------

# mesg_exit()
#
mesg_exit() {
  echo "$1" >&2
  exit $2
}

# usage_exit()
#
usage_exit() {
  # mesg_exit "usage: $PNAME [up|upload|down|download|unison|diff] [TARGETDIR]" $1
  cat >&2 << --EOF--

usage: $PNAME [up|upload|down|download|unison|diff] [DESTDIR]

  up, upload      : SRCDIR -> DSTDIR を rsync で実施
  down, download  : DSTDIR -> SRCDIR を rsync で実施
  unison          : SRCDIR <-> DSTDIR を unison で実施
  diff            : 差分比較のみ

現在位置が DIR1 ($DIR1) 側なら
  SRCDIR = \$DIR1/\$TARGET ($DIR1/$TARGET)
  DSTDIR = \$DIR2/\$TARGET ($DIR2/$TARGET)

現在位置が DIR2 ($DIR2) 側なら
  SRCDIR = \$DIR2/\$TARGET ($DIR2/$TARGET)
  DSTDIR = \$DIR1/\$TARGET ($DIR1/$TARGET)

[DESTDIR] を指定した場合は DSTDIR をその値で上書きする．

参考：常に自分がいる場所が下側で，ファイルをやり取りする相手が上側だと考えれば up と down は理解しやすいはず

--EOF--
  exit "$1"
}

# is_in_or_under1()
# 現在位置が base_dir 自身またはその直下かを判定
#
is_in_or_under1() {
  local current="$1"
  local base="$2"
  local parent
  parent="$(cd "$current/.." 2>/dev/null && pwd)"
  [[ "$current" == "$base" || "$parent" == "$base" ]]
}

# ----------------------------------------------------------

# テンプレート書き換え確認

# $PNAME が QQ-TEMPLATE.sh だったらファイル名を変更する必要がある
[[ "$PNAME" = "QQ-TEMPLATE.sh" ]] && mesg_exit "${PNAME}: Fatal: set file name ($PNAME) properly. aborted..." 99

# $PNAME が QQ-${TARGET}.sh でなければ，$TARGET とファイル名を一致させる必要がある
[[ "$PNAME" != "QQ-${TARGET}.sh" ]] && mesg_exit "${PNAME}: Fatal: set TARGET variable ($TARGET) properly. aborted... $PNAME / QQ-${TARGET}.sh" 98

# ----------------------------------------------------------

# 必要コマンド確認

# [ "x$(which rsync)" = "x" ]  && mesg_exit "${PNAME}: rsync is not installed. aborted..." 99
# [ "x$(which unison)" = "x" ] && mesg_exit "${PNAME}: unison is not installed. aborted..." 99

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || mesg_exit "${PNAME}: $1 is not installed. aborted..." 99
}

require_cmd rsync
require_cmd unison
require_cmd diff

# ----------------------------------------------------------

# 引数処理

# syncType="none"
# 
# if [ "x$1" = "x-h" -o "x$1" = "x--help" ]; then
#   usage_exit 9
#   :
# elif [ "x$1" = "xup" -o "x$1" = "xupload" ]; then
#   syncType="up"
#   shift
#   :
# elif [ "x$1" = "xdown" -o "x$1" = "xdownload" ]; then
#   syncType="down"
#   shift
#   :
# elif [ "x$1" = "xunison" ]; then
#   syncType="unison"
#   shift
#   :
# elif [ "x$1" = "xdiff" ]; then
#   syncType="diff"
#   shift
#   :
# fi
# 
# if [ "x$syncType" = "xnone" ]; then
#   usage_exit 9
#   :
# fi

[[ $# -lt 1 ]] && usage_exit 9

syncType=""

case "$1" in
  -h|--help)
    usage_exit 0
    ;;
  up|upload)
    syncType="up"
    shift
    ;;
  down|download)
    syncType="down"
    shift
    ;;
  unison)
    syncType="unison"
    shift
    ;;
  diff)
    syncType="diff"
    shift
    ;;
  *)
    usage_exit 9
    ;;
esac

# ----------------------------------------------------------

# 対象ディレクトリ確認

# if [ ! -d "$DIR1/$TARGET" ]; then
#   mesg_exit "${PNAME}: Can't find directory No.1 ($DIR1/$TARGET)" 2
#   :
# fi
# 
# if [ ! -d "$DIR2/$TARGET" ]; then
#   mesg_exit "${PNAME}: Can't find directory No.2 ($DIR2/$TARGET)" 3
#   :
# fi
# 
# CDIR1=$(pwd)
# CDIR2=$(cd ..; pwd)
# 
# if [ "x$CDIR1" = "x$DIR1" -o "x$CDIR2" = "x$DIR1" ]; then
#   SRCDIR="$DIR1/$TARGET"
#   DSTDIR="$DIR2/$TARGET"
# 
# elif [ "x$CDIR1" = "x$DIR2" -o "x$CDIR2" = "x$DIR2" ]; then
#   SRCDIR="$DIR2/$TARGET"
#   DSTDIR="$DIR1/$TARGET"
# 
# else
#   mesg_exit "${PNAME}: You must change directory to one of $DIR1 or $DIR2" 5
#     :
# fi
# 
# if [ "x$1" != "x" -a -d "$1" ]; then
# 	DSTDIR="$1"
# fi
# 
# echo "SRCDIR: $SRCDIR"
# echo "DSTDIR: $DSTDIR"
# 
# # echo "DEBUG: ($SRCDIR) ($DSTDIR)"
# # exit 90

ROOT1="$DIR1/$TARGET"
ROOT2="$DIR2/$TARGET"

[[ -d "$ROOT1" ]] || mesg_exit "${PNAME}: Can't find directory No.1 ($ROOT1)" 2
[[ -d "$ROOT2" ]] || mesg_exit "${PNAME}: Can't find directory No.2 ($ROOT2)" 3

CURDIR="$(pwd)"

if is_in_or_under1 "$CURDIR" "$DIR1"; then
  SRCDIR="$ROOT1"
  DSTDIR="$ROOT2"
elif is_in_or_under1 "$CURDIR" "$DIR2"; then
  SRCDIR="$ROOT2"
  DSTDIR="$ROOT1"
else
  mesg_exit "${PNAME}: You must change directory to one of $DIR1 or $DIR2 (or their direct children)" 5
fi

# 第2引数相当（ここまでくる間に shift しているので今は 第1引数) の $DESTDIR を上書き
if [[ $# -ge 1 ]]; then
  if [[ -d "$1" ]]; then
    DSTDIR="$1"
  else
    mesg_exit "${PNAME}: DESTDIR '$1' is not a directory" 6
  fi
fi

echo "SRCDIR: $SRCDIR"
echo "DSTDIR: $DSTDIR"

# ----------------------------------------------------------

# 除外設定

# opts=""
# opts="$opts --exclude=${PNAME}"
# opts="$opts --exclude=.Spotlight-V100"
# opts="$opts --exclude=.TemporaryItems"
# opts="$opts --exclude=.fseventsd"
# opts="$opts --exclude=.git*"
# opts="$opts --exclude='*.swp'"
# opts="$opts --exclude='*~'"
# opts="$opts --exclude='*.bak'"
# 
# # opts="$opts --exclude='*.md'"
# # opts="$opts --exclude='*.txt'"
# 
# optx=$(echo $opts | sed -e 's/--exclude=/-ignore "Regex /g' -e 's/\(Regex [^ ]*\) /\1" /g' -e 's/$/"/')
# 
# # echo "($opts)"
# # echo "($optx)"
# # exit 91

RSYNC_EXCLUDES=(
  "--exclude=$PNAME"
  "--exclude=.Spotlight-V100"
  "--exclude=.TemporaryItems"
  "--exclude=.fseventsd"
  "--exclude=.git*"
  "--exclude=*.swp"
  "--exclude=*~"
  "--exclude=*.bak"
)

UNISON_IGNORES=(
  "-ignore" "Name $PNAME"
  "-ignore" "Name .Spotlight-V100"
  "-ignore" "Name .TemporaryItems"
  "-ignore" "Name .fseventsd"
  "-ignore" "Path .git"
  "-ignore" "Regex .*\\.git.*"
  "-ignore" "Regex .*\\.swp"
  "-ignore" "Regex .*~"
  "-ignore" "Regex .*\\.bak"
)

# ----------------------------------------------------------

# 実行

# if [ "x$syncType" = "xup" ]; then
#   echo "${PNAME}: ${SRCDIR} -> ${DSTDIR}"
#   # echo $(echo rsync -avE $@ $opts ${SRCDIR}/ ${DSTDIR})
#   # eval $(echo rsync -avE $@ $opts ${SRCDIR}/ ${DSTDIR})
#   rsync -avE $@ $opts ${SRCDIR}/ ${DSTDIR}
#   :
# elif [ "x$syncType" = "xdown" ]; then
#   echo "${PNAME}: ${DSTDIR} -> ${SRCDIR}"
#   # echo $(echo rsync -avE $@ $opts ${DSTDIR})/ ${SRCDIR}
#   # eval $(echo rsync -avE $@ $opts ${DSTDIR})/ ${SRCDIR}
#   rsync -avE $@ $opts ${DSTDIR})/ ${SRCDIR}
#   :
# elif [ "x$syncType" = "xunison" ]; then
#   echo "${PNAME}: ${DSTDIR} <-> ${SRCDIR}"
#   # echo $(echo "unison -batch $SRCDIR $DSTDIR $optx")
#   # eval $(echo "unison -batch $SRCDIR $DSTDIR $optx")
#   unison -batch $SRCDIR $DSTDIR $optx"
#   :
# elif [ "x$syncType" = "xdiff" ]; then
#   echo "${PNAME}: Compare ${SRCDIR} and ${DSTDIR}"
#   echo "(diff)"
#   echo $(echo diff -r -q ${SRCDIR} ${DSTDIR})
#   eval $(echo diff -r -q ${SRCDIR} ${DSTDIR})
#   echo "Return Code = $?"
#   echo "(unison)"
#   unison -batch -noupdate "$SRCDIR" -noupdate "$DSTDIR" "$SRCDIR" "$DSTDIR"
#   echo "Return Code = $?"
#   :
# else
#   usage_exit 9
#   :
# fi

case "$syncType" in
  up)
    echo "${PNAME}: ${SRCDIR} -> ${DSTDIR}"
    rsync -avE "${RSYNC_EXCLUDES[@]}" "$SRCDIR/" "$DSTDIR/"
    rc=$?
    echo "Return Code = $rc"
    ;;
  down)
    echo "${PNAME}: ${DSTDIR} -> ${SRCDIR}"
    rsync -avE "${RSYNC_EXCLUDES[@]}" "$DSTDIR/" "$SRCDIR/"
    rc=$?
    echo "Return Code = $rc"
    ;;
  unison)
    echo "${PNAME}: ${SRCDIR} <-> ${DSTDIR}"
    unison -batch "$SRCDIR" "$DSTDIR" "${UNISON_IGNORES[@]}"
    rc=$?
    echo "Return Code = $rc"
    ;;
  diff)
    echo "${PNAME}: Compare ${SRCDIR} and ${DSTDIR}"
    echo "(diff -r -q)"
    diff -r -q "$SRCDIR" "$DSTDIR"
    rc=$?
    echo "Return Code = $rc"

    echo "(unison dry comparison)"
    unison -batch -noupdate "$SRCDIR" -noupdate "$DSTDIR" "$SRCDIR" "$DSTDIR"
    rc=$?
    echo "Return Code = $rc"
    ;;
  *)
    usage_exit 9
    ;;
esac

exit 0
