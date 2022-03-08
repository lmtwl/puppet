#!/bin/bash
#set -x
OPT=$1

usage()
{
	echo "usage:`basename $0` add|del 127.0.0.1 ctclist|cnclist"
	exit 1
}

case $OPT in
updateip|updateip) 
	[ $# -ne 4 ] && { usage ;}
	oldip=$2
	newip=$3
	file=$4
	grep $oldip $file  && { sed -i  "s/$oldip/$newip/g" $file ; } || { echo "没有找到源ip"; exit 1  ;}

;;
update|update)
	[ $# -ne 5 ] && { usage ;}
	oldtitle=$2
	newtitle=$3
	ip=$4
	file=$5
	grep "$oldtitle\[$ip\]" $file && { sed -i "s/$oldtitle\[$ip\]/$newtitle\[$ip\]/g" $file ;} ||{ echo "没有找到title" ;}

;;

add|Add)
	[ ]	

;;


*)usage
;;
esac


#sed -i  "s/$1/$2/g" $3 
