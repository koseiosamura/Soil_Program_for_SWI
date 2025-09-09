#!/bin/bash


#######################################################################################
#
#
#
#
#
#######################################################################################


set -e


init_pre_function(){
    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . mkdir_func.sh
    mkdir_RAP_function
    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . date_func.sh
    init_date_function
    
    for init_RAP_cycle in bin RAP log npy;
    do
	if [ ! -d ${WRDR}/Ens/${init_RAP_cycle} ];
	then
	    mkdir -p ${WRDR}/Ens/${init_RAP_cycle}
	fi
	if [ ! -d ${WRDR}/init/${init_RAP_cycle} ];
	then
	    mkdir -p ${WRDR}/init/${init_RAP_cycle}
	fi
    done
    unzip_init_RAP_function

    
}


unzip_init_RAP_function(){

    while [ ${start_init_unix} -le ${end_init_unix} ];
    do
	current_init_unix=${start_init_unix}
        current_init_date=$(date -d "@$current_init_unix" "+%Y%m%d%H%M%S")
	echo "${current_init_date}"
        
	local rddir=${RDR}/${current_init_date:0:4}/${current_init_date:5:1}
        local init_RAP_data=${JMA_Rader}${current_init_date:0:4}${current_init_date:5:1}${current_init_date:6:2}.RAP
	
        fileCheck_function ${rddir}/${init_RAP_data}
	
	if [ ! -s ${WRDR}/init/RAP/${init_RAP_data} ];
        then
            cp ${rddir}/${init_RAP_data} ${WRDR}/init/RAP
            ext="{init_RAP_data##*.}"
        else
            rm ${WRDR}/init/RAP/${init_RAP_data}
            cp ${rddir}/${init_RAP_data} ${WRDR}/init/RAP
            ext="{init_RAP_data##*.}"
        fi
         
	cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Pre/unzip_c
        
	gcc -std=c99 -O2 -o rapunzip_hourly rapunzip_hourly.c
        ./rapunzip_hourly ${WRDR}/init/RAP/${init_RAP_data} >> ${WRDR}/init/log/outpre.log
        mv *.bin ${WRDR}/init/bin
	
	log_init_RAP_fuction
	
	init_RAP_npy_function
    
	start_init_unix=$((start_init_unix + ${init_timehour} * ${timedelta}))
    done

}


log_init_RAP_fuction(){

    cat << EOF >> ${WRDR}/init/log/date_init.txt
START ${init_RAP_data}
      $(date)
EOF

}


init_RAP_npy_function(){
    
    init_date_cycle_start=${current_init_unix}
    init_date_cycle_end=$(($current_init_unix + $init_timehour * $timedelta - $timedelta))
    while [ ${init_date_cycle_start} -le ${init_date_cycle_end} ];
    do
	init_date_cycle_unix=${init_date_cycle_start}
	init_date_cycle=$(date -d "@$init_date_cycle_unix" "+%Y%m%d%H%M%S")
	local init_output_bin=${WRDR}/init/bin/output_${init_date_cycle:0:4}${init_date_cycle:4:2}${init_date_cycle:6:2}_${init_date_cycle:8:2}00.bin
	fileCheck_function ${init_output_bin}
	if [ "${JMA_Rader}" = "J" ];
	then
	    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Init/init_pre
	    export init_output_bin=${init_output_bin} 
	    export lon_interval=${lon_interval} 
	    export lat_interval=${lat_interval} 
	    export n_lon=${n_lon} 
	    export n_lat=${n_lat} 
	    export RAP_lon_max=${RAP_lon_max} 
	    export RAP_lat_max=${RAP_lat_max}
	    export pre_level=${pre_level}
	    export init_output_RAP_date=${init_date_cycle:0:4}${init_date_cycle:4:2}${init_date_cycle:6:2}${init_date_cycle:8:2}00
	    python3 init_pre_npy.py 
	    mv init_RAP_${init_output_RAP_date}.npy ${WRDR}/init/npy
	fi
	fileCheck_function ${WRDR}/init/npy/init_RAP_${init_output_RAP_date}.npy
	log_init_RAP_npy_function
	init_date_cycle_start=$(($init_date_cycle_start + $timedelta))
    done

}


log_init_RAP_npy_function(){

    cat << EOF >> ${WRDR}/init/log/npy_hourly.txt
${init_output_RAP_date}
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
