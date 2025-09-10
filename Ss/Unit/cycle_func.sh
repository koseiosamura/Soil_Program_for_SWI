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



cycle_RAP_function(){

    echo "========================================="
    echo "   Cycle 1hour"
    echo "       Init : ${c_yy}/${c_mm}/${c_dd} ${c_hh}:00"
    echo "       Anal : ${a_yy}/${a_mm}/${a_dd} ${a_hh}:00"
    echo "========================================="
    echo ${Log_cycleUnzip}
    unzip_RAP_function
    RAP_npy_function
    #exit
    

}



unzip_RAP_function(){

    local rddir=${RDR}/${c_yy}/${c_mm:1:1}
    local RAP_data=${JMA_Rader}${c_yy}${c_mm:1:1}${c_dd}.RAP
    fileCheck_function ${rddir}/${RAP_data}
    if [ ! -s ${WRDR}/Ens/RAP/${RAP_data} ];
    then
        cp ${rddir}/${RAP_data} ${WRDR}/Ens/RAP
        ext="{init_RAP_data##*.}"
    else
        rm ${WRDR}/Ens/RAP/${RAP_data}
        cp ${rddir}/${RAP_data} ${WRDR}/Ens/RAP
        ext="{init_RAP_data##*.}"
    fi
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Pre/unzip_c
    gcc -std=c99 -O2 -o rapunzip_hourly rapunzip_hourly.c
    ./rapunzip_hourly ${WRDR}/Ens/RAP/${RAP_data} >> ${WRDR}/Ens/log/outpre.log
    mv *.bin ${WRDR}/Ens/bin
    log_RAP_function
    
}


RAP_npy_function(){

    local dateCycle_RAP=${dateCycle_Sta}
    while [ ${dateCycle_RAP} -le ${dateCycle_End} ];
    do
	local dateCycle=$(date -d "@$dateCycle_RAP" "+%Y%m%d%H%M%S")
	local cy_yy=${dateCycle:0:4}
	local cy_mm=${dateCycle:4:2}
	local cy_dd=${dateCycle:6:2}
	local cy_hh=${dateCycle:8:2}
	local output_bin=${WRDR}/Ens/bin/output_${cy_yy}${cy_mm}${cy_dd}_${cy_hh}00.bin
	fileCheck_function ${output_bin}
	if [ "${JMA_Rader}" = "J" ];
        then
            cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Pre/npy_pre
            export output_bin=${output_bin}
            export lon_interval=${lon_interval}
            export lat_interval=${lat_interval}
            export n_lon=${n_lon}
            export n_lat=${n_lat}
            export RAP_lon_max=${RAP_lon_max}
            export RAP_lat_max=${RAP_lat_max}
            export pre_level=${pre_level}
            export output_RAP_date=${cy_yy}${cy_mm}${cy_dd}${cy_hh}00
            python3 pre_npy.py
            mv RAP_${output_RAP_date}.npy ${WRDR}/Ens/npy
	    log_npy_function
        fi
	dateCycle_RAP=$((${dateCycle_RAP} + ${timedelta}))
    done

}


cycle_initCheck_function(){
    
    local dateCycle_check=${dateCycle_Sta}
    if [ ! -s ${WIDR}/Ens/data/${IDW_RRA_file} ];
    then
	fileCheck_function ${WIDR}/Ens/data/${IDW_RRA_file}
	exit
    fi
    if [ ${dateCycle_check} -eq $((${start_unix} + ${timedelta})) ];
    then
	for SWI_cycle in SWI First Second Third;
	do
	    if [ ! -s ${WINDR}/npy/${SWI_cycle}/${SWI_cycle}_anal_${c_yy}${c_mm}${c_dd}${c_hh}00.npy ];
	    then
		fileCheck_function ${WINDR}/npy/${SWI_cycle}/${SWI_cycle}_anal_${c_yy}${c_mm}${c_dd}${c_hh}00.npy
		exit
	    fi
	done
    else
    	for SWI_cycle in SWI First Second Third;
	do
	    for ens_member in `seq -w 001 ${end_member}`
	    do
		if [ ! -s ${WEDR}/${SWI_cycle}/${ens_member}/${SWI_cycle}_anal_${c_yy}${c_mm}${c_dd}${c_hh}00.npy ];
		then
		    fileCheck_function ${WEDR}/${SWI_cycle}/${ens_member}/${SWI_cycle}_anal_${c_yy}${c_mm}${c_dd}${c_hh}00.npy
		    exit
		fi
	    done
	done
    fi
    while [ ${dateCycle_check} -le ${dateCycle_End} ];
    do
	local dateCycle=$(date -d "@$dateCycle_check" "+%Y%m%d%H%M%S")
        echo "${dateCycle}"
        local cy_yy=${dateCycle:0:4}
        local cy_mm=${dateCycle:4:2}
        local cy_dd=${dateCycle:6:2}
        local cy_hh=${dateCycle:8:2}
	local output_RAP_date=${cy_yy}${cy_mm}${cy_dd}${cy_hh}00
	if [ ! -s ${WRDR}/Ens/npy/RAP_${output_RAP_date}.npy ];
	then
	    fileCheck_function ${WRDR}/Ens/npy/RAP_${output_RAP_date}.npy
	    exit
	fi
	for ens_member in `seq -w 001 ${end_member}`
	do
	    if [ ! -s ${IRD}/${ens_member}/${cond_kind}_${kind}_${output_RAP_date}.grib2 ];
	    then
		fileCheck_function ${IRD}/${ens_member}/${cond_kind}_${kind}_${output_RAP_date}.grib2
		exit
	    fi
	done
	dateCycle_check=$((${dateCycle_check} + ${timedelta}))
    done 
    if [ ! -s ${WIDR}/Ens/data/${IDW_RRA_file} ];
    then
        fileCheck_function ${WIDR}/Ens/data/${IDW_RRA_file}
        exit
    fi
    
    
}



log_RAP_function(){

    cat <<EOF >> ${WRDR}/Ens/log/date_init.txt
START ${RAP_data}
      $(date)
EOF

}


log_npy_function(){

    cat <<EOF >> ${WRDR}/Ens/log/npy_hourly.txt
${output_RAP_date}
EOF

}



fileCheck_function(){

    if [ ! -s $1 ];
    then
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find $1"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi

}

