#!/bin/bash

#
#
#
#
#
#
#
#



set -e


End_cycle_function(){

    if [ $1 -gt $2 ];
    then
	End_cycle_date=$(date -d "@$1" "+%Y%m%d%H%M%S")
	End_now=$(date "+%Y-%m-%d %H:%M:%S")
	
	echo "=============================="
	echo "   End Cycle"
	echo ""
	echo "      ${End_cycle_date:0:12}"
	echo "      ${End_now}"
	echo ""
	echo "=============================="
	exit
    fi

}
