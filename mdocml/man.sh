#!/bin/sh

# man - a simple man program for ASCII pages
# Copyright (c) 2008 Matthew Hiles
#
# Licensed under GPLv2 or later, see file LICENSE in this tarball for details.

## requires: find, head, sort, tr, cat, and grep/egrep
## optional: zcat, bzcat, less

if [ -z "$MANPATH" ]; then
	echo "Warning: MANPATH is not set, assuming /usr/share/man." >&2
	MANPATH=/usr/share/man
fi

case $# in
1)
	pagearg=$1 ;;
2)
	section=man$1
	pagearg=$2 ;;
*)
	echo "Usage: man [section] <manpage>"
	exit
esac

paths=`echo "$MANPATH" | tr ":" " "`
pagefile=`find $paths | grep "/$section" | grep "/$pagearg\." | sort | head -n1`

if [ -z "$pagefile" ]; then
	echo -n No manual entry for $pagearg
	[ $section ] && echo -n " in section $1 of the manual."
	echo
	exit
fi

[ "$PAGER" ] || PAGER=less
tty -s <&1 || PAGER=cat

MANWIDTH=${MANWIDTH:-78}
if [ $MANWIDTH = 0 ]; then
    MANWIDTH=$(($(stty size | awk '{print $2}') - 2))
fi

case "$pagefile" in
*.bz2)
	exec bzcat "$pagefile" | mandoc -Tutf8 -Owidth=$MANWIDTH | "$PAGER" ;;
*.gz)
	exec zcat "$pagefile" | mandoc -Tutf8 -Owidth=$MANWIDTH | "$PAGER" ;;
*)
	exec mandoc -Tutf8 -Owidth=$MANWIDTH "$pagefile" | "$PAGER" ;;
esac

paths=
pagefile=
pagearg=
section=
