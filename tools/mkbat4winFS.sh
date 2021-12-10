#!/bin/sh

# mkbat4winFS.sh

# ----------------------------------------------------------

#
# Usage: mkbat4winFS.sh [[-d|/d] directories] > foo.bat
#
# Description:
# Create a windows batch file to replace the UNIX symbolic link in the current directory with a windows-style symbolic link
#
# 説明：
# カレントディレクトリの UNIX シンボリックリンクを Windows スタイルのシンボリックリンクに置き換えるための Windows バッチファイルを生成する
#
# Remarks:
# Save the output of this script as a batch file (.bat extension) in the target directory and run it on Windows PowerShell with administrative privileges as follows:
#
#     PS> cd c:\...\target\directory
#     PS> .\savedFile.bat
#        or
#     PS> .\savedFile.bat -d dir1 dir2 ...
#
# 備考：
# このスクリプトの出力をバッチファイル（拡張子.bat）として対象ディレクトリに保存し，Windows PowerShell上で管理者権限で実行すること
#
#     PS> cd c:\...\target\directory
#     PS> .\savedFile.bat
#        or
#     PS> .\savedFile.bat -d dir1 dir2 ...
#

# ----------------------------------------------------------

#
# Last update: Mon Oct  4 06:55:42 JST 2021
#

PNAME=$(basename $0)
DATETIME=$(LANG=C date)

OPTION1="."
OPTION2=

usage() {
    echo "usage: $0 [[-d|/d] directories]"
}

if [ "x$1" = "x-h" -o "x$1" = "x--help" ]; then
    usage
    exit 9

elif [ "x$1" = "x-d" -o "x$1" = "x/d" ]; then
    OPTION2="/d"
    shift
    if [ "x$1" = "x" ]; then
	usage
	exit 9
    fi
    OPTION1="-d $@"
fi

echo "rem"
echo "rem Created by $PNAME ($DATETIME)"
echo "rem"
ls -l $OPTION1 | egrep -e '->' | awk '{print $9, $11}' | sed 's|/|\\|g' | awk -v "opt=$OPTION2" '{printf "del %s\ncmd.exe /c mklink %s %s %s\n",$1,opt,$1,$2}'
