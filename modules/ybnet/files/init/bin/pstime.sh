#!/bin/bash
pid=$1
if [ "$pid" == "" ]; then
    echo "plese pid：./pstart pid  "
    echo " ./pstart 1"
    exit;
fi


etime=$(ps -p $pid -o etime=)
if [ "$etime" == "" ]; then
    echo "NO pid: pid=$pid"
    exit;
fi
now=$(date "+%s")

etime=${etime//:0/ }
etime=${etime//-0/ }

etime=${etime//-/ }
etime=${etime//:/ }
item_arr=( $etime );
arr_count=${#item_arr[@]}
if [ $arr_count == 2 ];then
    etime="0 0 $etime"    
elif [ $arr_count == 3 ];then
    etime="0 $etime"    
fi

power=(86400 3600 60 1 )
i=0;
seconds=0;
for v in $etime ;do
    let "seconds=seconds+${v}*${power[$i]}"
    let "i=i+1"
done
#echo $seconds;
let "starttime=now-seconds"
date -d "1970-01-01 UTC $starttime seconds" +"%F %T" 

