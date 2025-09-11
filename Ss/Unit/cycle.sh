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
    anal_unix=$((${current_unix} + ${timedelta} * ${timehour}))
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
    cycle_RAP_function
    echo "${Log_cycleInit}"
    cycle_initCheck_function
    SWI_cycle_function
    
    current_unix=$((${current_unix} + ${timehour} * ${timedelta}))
    
done
