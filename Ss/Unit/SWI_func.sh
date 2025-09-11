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


SWI_cycle_function(){

    dateCycle_SWI_unix=$((${dateCycle_Sta} - ${timedelta}))
    dateCycle_anal_unix=${dateCycle_Sta}
    while [ ${dateCycle_SWI_unix} -lt ${dateCycle_End} ];
    do
	if [ ${dateCycle_SWI_unix} -gt ${end_unix} ];
	then
	    break
	fi
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
	    SWI_RRA_function ${ens_member}
	done
	dateCycle_SWI_unix=$((${dateCycle_SWI_unix} + ${timedelta}))
	dateCycle_anal_unix=$((${dateCycle_anal_unix} + ${timedelta}))
    done
    echo "${Log_cycleRRA}"
    
    dateCycle_RAP_unix=$((${dateCycle_Sta} - ${timedelta}))
    dateCycle_RAP_anal_unix=${dateCycle_Sta}
    if [ ${dateCycle_RAP_unix} -eq ${start_unix} ];
    then
        for SWI_cycle in SWI First Second Third;
        do
            cp ${WINDR}/npy/${SWI_cycle}/${SWI_cycle}_anal_${WDR_LETKF}.npy ${WEDR}/${SWI_cycle}/RAP
        done
    fi
    while [ ${dateCycle_RAP_unix} -lt ${dateCycle_End} ];
    do
	. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Job/Job.sh
        End_cycle_function ${dateCycle_RAP_unix} ${end_unix}
	SWI_RAP_function
	dateCycle_RAP_unix=$((${dateCycle_RAP_unix} + ${timedelta}))
	dateCycle_RAP_anal_unix=$((${dateCycle_RAP_anal_unix} + ${timedelta}))
    done
    echo "${Log_cycleRAP}"
    
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
    done
    local Para_data=${WPDR}/${Parameter_file}
    export RAP_npy=${WRDR}/Ens/npy/RAP/RAP_${dateCycle_anal:0:12}.npy
    export output_RAP_date=${dateCycle_anal:0:12}
    local parameter=${Para_data}
    export parameter
    python3 RAP_SWI.py
    for SWI_cycle in SWI First Second Third;
    do
        mv ${SWI_cycle}_anal_${dateCycle_anal:0:12}.npy ${WEDR}/${SWI_cycle}/RAP
    done

}
