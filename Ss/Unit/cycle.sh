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

. ./cycle_func.sh
. ./SWI_func.sh
. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Job/Job.sh 


cd  /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. mkdir_func.sh
mkdir_ensemble_function


cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. date_func.sh
date_function


current_unix=${start_unix}
while [ ${current_unix} -lt ${end_unix} ];
do
    
    current_date=$(date -d "@$current_unix" "+%Y%m%d%H%M%S")
    
    if  [ "$current_unix" == "$start_unix" ];
    then
	anal_unix=$((${current_unix}+${init_timehour}*${timedelta}-${timedelta}*${start_hmm}))
    else
	anal_unix=$((${current_unix} + ${timedelta} * ${timehour}))
    fi
    anal_date=$(date -d "@$anal_unix" "+%Y%m%d%H%M%S")
    dateCycle_Sta=$((${current_unix} + ${timedelta}))
    dateCycle_End=${anal_unix}
    
    
    c_yy=${current_date:0:4}
    c_mm=${current_date:4:2}
    c_dd=${current_date:6:2}
    c_hh=${current_date:8:2}
    a_yy=${anal_date:0:4}
    a_mm=${anal_date:4:2}
    a_dd=${anal_date:6:2}
    a_hh=${anal_date:8:2}


    Start_cycle_function >> ${WDR}/${WDR_date}/log

    echo "========================================="
    echo "   Cycle 1hour"
    echo "       Init : ${c_yy}/${c_mm}/${c_dd} ${c_hh}:00"
    echo "       Anal : ${a_yy}/${a_mm}/${a_dd} ${a_hh}:00"
    echo "========================================="


    #cycle_RAP_function
    echo "${Log_cycleInit}"
    cycle_initCheck_function >> ${WDR}/${WDR_date}/log
    SWI_cycle_function 
    if  [ "$current_unix" == "$start_unix" ];
    then
	current_unix=$((${current_unix}+${init_timehour}*${timedelta}-${timedelta}*${start_hmm}))
    else
	current_unix=$((${current_unix} + ${timehour} * ${timedelta}))
    fi

done


echo "========================================="
echo "   Cycle 1hour"
echo "       RAP Numerical SWI"
echo "       RAP : JST    SWI ; UTC"
echo "========================================="


RAP_start_Job_function >> ${WDR}/${WDR_date}/log

step=1
JST_unix=${start_JST_unix}
UTC_unix=${start_unix}
while [ ${JST_unix} -lt ${end_JST_unix} ];
do
    
    echo "--- Step 00${step}"

    JST_date=$(date -d "@$JST_unix" "+%Y%m%d%H%M%S")
    
    if  [ "$JST_unix" == "$start_JST_unix" ];
    then
        anal_JST_unix=$((${JST_unix}+${init_timehour}*${timedelta}-${timedelta}*${JST_date:8:2}))
    else
        anal_JST_unix=$((${JST_unix} + ${timedelta} * ${timehour}))
    fi

    dateCycle_Sta_RAP=${JST_unix}
    dateCycle_End_RAP=${anal_JST_unix}


    if  [ "$JST_unix" == "$start_JST_unix" ];
    then
        anal_UTC_unix=$((${UTC_unix}+${init_timehour}*${timedelta}-${timedelta}*${JST_date:8:2}))
    else
	anal_UTC_unix=$((${UTC_unix} + ${timedelta} * ${timehour}))
    fi


    dateCycle_Sta_UTC=$(($UTC_unix + $timedelta))
    dateCycle_End_UTC=${anal_UTC_unix}
    
    cj_yy=${JST_date:0:4}
    cj_mm=${JST_date:4:2}
    cj_dd=${JST_date:6:2}
    cj_hh=${JST_date:8:2}

    cycle_RAP_function
    SWI_RAP_cycle_function

    if  [ "$JST_unix" == "$start_JST_unix" ];
    then
        JST_unix=$((${JST_unix}+${init_timehour}*${timedelta}-${timedelta}*${JST_date:8:2}))
	UTC_unix=$((${UTC_unix}+${init_timehour}*${timedelta}-${timedelta}*${JST_date:8:2}))
    else
        JST_unix=$((${JST_unix} + ${timehour} * ${timedelta}))
	UTC_unix=$((${UTC_unix} + ${timehour} * ${timedelta}))
    fi
    step=$(($step + 1))

done

