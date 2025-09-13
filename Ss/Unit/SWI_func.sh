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
. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Job/Job.sh




SWI_cycle_function(){

    echo "${Log_cycleRRA}"
    dateCycle_SWI_unix=$((${dateCycle_Sta} - ${timedelta}))
    dateCycle_anal_unix=${dateCycle_Sta}
    echo "### Ensemble start ###" >> ${WDR}/${WDR_date}/log
    ENS_start_Job_function >> ${WDR}/${WDR_date}/log 
    while [ ${dateCycle_SWI_unix} -lt ${dateCycle_End} ];
    do
	Ensemble_cycle_function >> ${WDR}/${WDR_date}/log
	dateCycle_SWI_unix=$((${dateCycle_SWI_unix} + ${timedelta}))
	dateCycle_anal_unix=$((${dateCycle_anal_unix} + ${timedelta}))
    done
    echo "### Ensemble end ###" >> ${WDR}/${WDR_date}/log
    
    echo "${Log_cycleRAP}"
    echo ""
    echo ""

    RAP_start_Job_function >> ${WDR}/${WDR_date}/log
    echo "### RAP start ###" >> ${WDR}/${WDR_date}/log
    dateCycle_RAP_unix=$((${dateCycle_Sta} - ${timedelta}))
    dateCycle_RAP_anal_unix=${dateCycle_Sta}
    
    if [ ${dateCycle_RAP_unix} -eq ${start_unix} ];
    then
        for SWI_cycle in SWI First Second Third;
        do
            cp ${WINDR}/npy/${SWI_cycle}/${SWI_cycle}_anal_${WDR_LETKF}.npy ${WEDR}/${SWI_cycle}/RAP
        done
    fi
    mep=1
    while [ ${dateCycle_RAP_unix} -lt ${dateCycle_End} ];
    do
	End_cycle_function ${dateCycle_RAP_unix} ${end_unix}
	SWI_RAP_function >> ${WDR}/${WDR_date}/log
	dateCycle_RAP_unix=$((${dateCycle_RAP_unix} + ${timedelta}))
	dateCycle_RAP_anal_unix=$((${dateCycle_RAP_anal_unix} + ${timedelta}))
	mep=$(($mep + 1))
    done
    echo "### RAP end ###" >> ${WDR}/${WDR_date}/log
    
    
}


 

Ensemble_cycle_function(){

    
    
    if [ ${dateCycle_SWI_unix} -gt ${end_unix} ];
    then
        break
    fi
    echo " --- Mep Start 001 >>>> 031 ---"
    for ens_member in `seq -w 001 ${end_member}`
    do
        if [ ! -d ${WRDR}/Ens/npy/RRA/${ens_member} ];
        then
            mkdir -p ${WRDR}/Ens/npy/RRA/${ens_member}
        fi
        if [ ${dateCycle_SWI_unix} -eq ${start_unix} ];
        then
            for SWI_cycle in SWI First Second Third;
            do
                cp ${WINDR}/npy/${SWI_cycle}/${SWI_cycle}_anal_${WDR_LETKF}.npy ${WEDR}/${SWI_cycle}/${ens_member}
            done
        fi
	
        SWI_RRA_function ${ens_member} >> ${WDR}/${WDR_date}/log
    done


}


SWI_RRA_function(){
    
    
    local dateCycle_SWI=$(date -d "@$dateCycle_SWI_unix" "+%Y%m%d%H%M%S")
    local dateCycle_anal=$(date -d "@$dateCycle_anal_unix" "+%Y%m%d%H%M%S")
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Tank/RRA
    
    export input_RRA_date=${dateCycle_anal:0:12}
    export RRA_data=${IRD}/$1/${cond_kind}_${kind}_${dateCycle_anal:0:12}.grib2
    export IDW_RRA_data=${WIDR}/Ens/data/${IDW_RRA_file}
    export IDW_SWI_data=${WIDR}/RAP/data/${IDW_SWI_file}
    python3 trra.py
    mv RRA_${dateCycle_anal:0:12}.npy ${WRDR}/Ens/npy/RRA/$1
    for SWI_cycle in SWI First Second Third;
    do
        local varname=${SWI_cycle}_data
        local SWI_valus=${WEDR}/${SWI_cycle}/${ens_member}/${SWI_cycle}_anal_${dateCycle_SWI:0:12}.npy
        if [ ! -s ${SWI_valus} ];
        then
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            echo "  CANNOT find ${SWI_valus}"
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            exit
        fi
	
        local ${varname}=${SWI_valus}
        export ${varname}
    done
    local Para_data=${WPDR}/${Parameter_file}
    export RRA_npy=${WRDR}/Ens/npy/RRA/$1/RRA_${dateCycle_anal:0:12}.npy
    export output_Ens_date=${dateCycle_anal:0:12}
    local parameter=${Para_data}
    export parameter
    python3 RRA_SWI.py
    
    for SWI_cycle in SWI First Second Third;
    do
        mv ${SWI_cycle}_anal_${dateCycle_anal:0:12}.npy ${WEDR}/${SWI_cycle}/${ens_member}
    done

}



SWI_RAP_function(){

    echo "Mep Start 0${mep}"
    local dateCycle_SWI=$(date -d "@$dateCycle_RAP_unix" "+%Y%m%d%H%M%S")
    local dateCycle_anal=$(date -d "@$dateCycle_RAP_anal_unix" "+%Y%m%d%H%M%S")
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Tank/RAP
    for SWI_cycle in SWI First Second Third;
    do
        local varname=${SWI_cycle}_data
        local SWI_valus=${WEDR}/${SWI_cycle}/RAP/${SWI_cycle}_anal_${dateCycle_SWI:0:12}.npy
        if [ ! -s ${SWI_valus} ];
        then
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            echo "  CANNOT find ${SWI_valus}"
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            exit
        fi
        local ${varname}=${SWI_valus}
        export ${varname}
	#echo "--- file check Initial ${SWI_cycle} Data ---"
    done
    

    local Para_data=${WPDR}/${Parameter_file}
    export RAP_npy=${WRDR}/Ens/npy/RAP/RAP_${dateCycle_anal:0:12}.npy
    export output_RAP_date=${dateCycle_anal:0:12}
    local parameter=${Para_data}
    export parameter
    echo "    --- START  RAP SWI ---"
    python3 RAP_SWI.py
    
    for SWI_cycle in SWI First Second Third;
    do
        mv ${SWI_cycle}_anal_${dateCycle_anal:0:12}.npy ${WEDR}/${SWI_cycle}/RAP
    done
    echo "### RAP end ###"

}
