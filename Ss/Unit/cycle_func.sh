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

    echo "========================================="
    echo "   Cycle 1hour"
    echo "       Init : ${c_yy}/${c_mm}/${c_dd} ${c_hh}:00"
    echo "       Anal : ${a_yy}/${a_mm}/${a_dd} ${a_hh}:00"
    echo "========================================="
    unzip_RAP_function
    echo ${Log_cycleUnzip}
    exit
    

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
    ./rapunzip_hourly ${WRDR}/Ens/RAP/${RAP_data} > ${WRDR}/Ens/log/outpre.log
    mv *.bin ${WRDR}/Ens/bin
    log_RAP_function
    RAP_npy_function

}


RAP_npy_function(){

    #dateCycle_Sta=$((${current_unix} + ${timedelta}))
    #dateCycle_End=$((${current_unix} + ${timehour} * ${timedelta}))
    while [ ${dateCycle_Sta} -le ${dateCycle_End} ];
    do
	dateCycle_unix=${dateCycle_Sta}
	dateCycle=$(date -d "@$dateCycle_unix" "+%Y%m%d%H%M%S")
	#R=$(date -d "@$dateCycle_End" "+%Y%m%d%H%M%S")
	echo "${dateCycle}"
	cy_yy=${dateCycle:0:4}
	cy_mm=${dateCycle:4:2}
	cy_dd=${dateCycle:6:2}
	cy_hh=${dateCycle:8:2}
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
	#exit
	dateCycle_Sta=$((${dateCycle_Sta} + ${timedelta}))
    done

}


log_RAP_function(){

    cat <<EOF > ${WRDR}/Ens/log/date_init.txt
START ${RAP_data}
      $(date)
EOF

}


log_npy_function(){

    cat <<EOF > ${WRDR}/Ens/log/npy_hourly.txt
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

