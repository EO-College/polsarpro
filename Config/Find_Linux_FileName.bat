#!/bin/sh
### usage: Find_Linux_FileName filename	; return the filename if exists
###					; return nothing if not

which $1 &> /dev/null && echo $1 && exit 0

exit 0

