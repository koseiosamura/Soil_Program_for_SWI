#!/bin/bash


#==========================================================================
#
#   idw_RRA.sh 
#       
#       1. Lon Lat change from RRA to JMA_SWI
#
#
#
#==========================================================================

set -e
. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Job/Job.sh


 

RRA_idw_function(){

    RRA_idw_Job_function
    echo "### RRA IDW start ###"
    if [ ! -s ${IRD}/${start_member}/${IDW_RRA_grib} ];
    then
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${IRD}/${start_member}/${IDW_RRA_grib}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    cp ${IRD}/${start_member}/${IDW_RRA_grib} ${WIDR}/Ens/bin
    IDW_RRA_bin=${WIDR}/Ens/bin/${IDW_RRA_grib}
    if [ ! -s ${IDW_RRA_bin} ];
    then
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${IDW_RRA_bin}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Idw/idw_RRA
    export IDW_RRA_bin=${IDW_RRA_bin}
    export IDW_SWI=${WINDR}/npy/SWI/SWI_anal_${start_ymm}${start_mmm}${start_dmm}${start_hmm}00.npy
    export R=${R}
    export k=${k}
    export IDW_RRA_file=${IDW_RRA_file}
    python3 idw_RRA.py
    mv ${IDW_RRA_file} ${WIDR}/Ens/data
    echo "### RRA IDW END ###"

}
