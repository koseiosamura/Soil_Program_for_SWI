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


set -e


date_function(){
    

    start_date=$(printf "%04d-%02d-%02d %02d:00:00" $((10#$start_ymm)) $((10#$start_mmm)) $((10#$start_dmm)) $((10#$start_hmm)))
    end_date=$(printf "%04d-%02d-%02d %02d:00:00" $((10#$end_ymm)) $((10#$end_mmm)) $((10#$end_dmm)) $((10#$end_hmm)))

    start_unix=$(date -d "$start_date" +%s)
    end_unix=$(date -d "$end_date" +%s)

}


init_date_function(){

    date_function
    #if [ "$start_hmm" != 00 ];
    #then
	
    init_timedelta=$(( init_timeday * init_timehour * timedelta ))
    start_init_unix=$((start_unix - (init_timedelta - timedelta)))
    end_init_unix=${start_unix}
    start_init_date=$(date -d "@$start_init_unix" "+%Y%m%d%H%M%S")
    end_init_date=$(date -d "@$end_init_unix" "+%Y%m%d%H%M%S")

    
}





