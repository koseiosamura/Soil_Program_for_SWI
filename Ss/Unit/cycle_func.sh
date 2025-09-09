#!/bin/bash


#
#
#
#
#
#
#
#
#
#



cycle_function(){

    while [ ${start_unix} -le ${end_unix} ];
    do
	current_unix=${start_unix}
	current_date=$(date -d "@$current_unix" "+%Y%m%d%H%M%S")
	anal_unix=$((${start_unix} + ${timedelta}))
	anal_date=$(date -d "@$anal_unix" "+%Y%m%d%H%M%S")
	echo "${current_date}"
	echo "${anal_date}"
	local c_yy=${current_date:0:4}
	local c_mm=${current_date:4:2}
	local c_dd=${current_date:6:2}
	local c_hh=${current_date:8:2}
	local a_yy=${anal_date:0:4}
	local a_mm=${anal_date:4:2}
	local a_dd=${anal_date:6:2}
	local a_hh=${anal_date:8:2}
	
	exit
    done


}
