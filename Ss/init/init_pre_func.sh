#!/bin/bash


#######################################################################################
#
#
#
#
#
#######################################################################################


set -e
. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Job/Job.sh




init_pre_function(){
    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . mkdir_func.sh
    mkdir_RAP_function
    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . date_func.sh
    init_date_function
    

    echo ""
    echo "Make Initial Data START >>>>>>> ${start_init_date}"
    echo "Make Initial Data END   >>>>>>> ${end_init_date}"
    echo ""
    echo ""
    echo "==============================="
    echo "          START UNZIP"
    echo "==============================="
    

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
    echo "--- END make DIR"
    
    
    unzip_init_RAP_function >> ${WDR}/${WDR_date}/log
    echo "--- END Unzip RAP"
    
}


unzip_init_RAP_function(){

    echo ""
    echo "*******************************************"
    echo "              START Unzip "
    echo "*******************************************"
    echo ""
    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Pre/
    cp -r unzip_c ${WDR}/${WDR_date}
    local num=1
    current_init_unix=${start_init_unix}
    current_init_JST=${init_start_JST_unix}
    
    while [ ${current_init_JST} -le ${init_end_JST_unix} ];
    do
	echo " Mep 00${num}"
	current_init_date=$(date -d "@$current_init_unix" "+%Y%m%d%H%M%S")
	init_JST_date=$(date -d "@$current_init_JST" "+%Y%m%d%H%M%S")
	
	#rddir=${RDR}/${current_init_date:0:4}/${current_init_date:5:1}
        #init_RAP_data=${JMA_Rader}${current_init_date:0:4}${current_init_date:5:1}${current_init_date:6:2}.RAP
	rddir=${RDR}/${init_JST_date:0:4}/${init_JST_date:5:1}
	init_RAP_data=${JMA_Rader}${init_JST_date:0:4}${init_JST_date:5:1}${init_JST_date:6:2}.RAP

        fileCheck_function ${rddir}/${init_RAP_data}
	
	if [ ! -s ${WRDR}/init/RAP/${init_RAP_data} ];
        then
            cp ${rddir}/${init_RAP_data} ${WRDR}/init/RAP
        else
            rm ${WRDR}/init/RAP/${init_RAP_data}
            cp ${rddir}/${init_RAP_data} ${WRDR}/init/RAP
        fi
         
	cd ${WDR}/${WDR_date}/unzip_c
	gcc -std=c99 -O2 -o rapunzip_hourly rapunzip_hourly.c
        ./rapunzip_hourly ${WRDR}/init/RAP/${init_RAP_data} >> ${WRDR}/init/log/outpre.log
        mv *.bin ${WRDR}/init/bin
	echo "     ---- gcc -std=c99 -O2 -o rapunzip_hourly JST ${init_JST_date}"

	log_init_RAP_fuction
	
	#init_RAP_npy_function ${current_init_unix}
	init_RAP_npy_function ${current_init_JST} ${current_init_unix}
	if [ "$current_init_JST" == "$init_start_JST_unix" ];
	then
	    #current_init_unix=$((${current_init_unix}+${init_timehour}*${timedelta}-${timedelta}*${start_hmm}-${timedelta}))
	    current_init_JST=$((${current_init_JST}+${init_timehour}*${timedelta}-${timedelta}*${init_JST_date:8:2}))
	    current_init_unix=$((${current_init_unix}+${init_timehour}*${timedelta}-${timedelta}*${init_JST_date:8:2}))
	else
	    current_init_JST=$((${current_init_JST} + ${init_timehour} * ${timedelta}))
	    current_init_unix=$((${current_init_unix} + ${init_timehour} * ${timedelta}))
	fi
	num=$(($num + 1))
    done

}


log_init_RAP_fuction(){

    cat << EOF >> ${WRDR}/init/log/date_init.txt
START ${init_RAP_data}
      $(date)
EOF

}


init_RAP_npy_function(){
    
    local init_UTC_cycle_start=$2
    local init_JST_cycle_start=$1
    local start_hmm_JST=${init_JST_cycle_start:8:2}
    #if [ ${init_date_cycle_start} -eq ${start_init_unix} ];
    if [ ${init_UTC_cycle_start} -eq ${init_start_JST_unix} ];
    then
	init_JST_cycle_end=$(($1 + $init_timehour * $timedelta - $start_hmm_JST * $timedelta))
    else
    	init_JST_cycle_end=$(($1 + $init_timehour * $timedelta))
    fi
    break_unix=$(($1 + $init_timehour * $timedelta))
    break_date=$(date -d "@$break_unix" "+%Y%m%d%H%M%S")
    #while [ ${init_date_cycle_start} -lt ${init_date_cycle_end} ];
    while [ ${init_JST_cycle_start} -lt ${init_JST_cycle_end} ];
    do
	local init_date_cycle=$(date -d "@$init_UTC_cycle_start" "+%Y%m%d%H%M%S")
	local init_JST_cycle=$(date -d "@$init_JST_cycle_start" "+%Y%m%d%H%M%S")
	#echo "${init_date_cycle}"
	#echo "${init_JST_cycle}"
	#END=$(date -d "@$init_date_cycle_end" "+%Y%m%d%H%M%S")
	#echo "${init_date_cycle}"
	#echo "${END}" 
	if [ ${init_JST_cycle:6:2}${init_JST_cycle:8:2} -eq ${break_date:6:2}00 ];
	then
	    break
	fi
	
	init_output_bin=${WRDR}/init/bin/output_${init_JST_cycle:0:4}${init_JST_cycle:4:2}${init_JST_cycle:6:2}_${init_JST_cycle:8:2}00.bin
	
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
	init_JST_cycle_start=$(($init_JST_cycle_start + $timedelta))
	init_UTC_cycle_start=$(($init_UTC_cycle_start + $timedelta))
    done
    echo "     ---- python3 init_pre_npy.py"

}


log_init_RAP_npy_function(){

    cat << EOF >> ${WRDR}/init/log/npy_hourly.txt
${init_JST_cycle:0:4}${init_JST_cycle:4:2}${init_JST_cycle:6:2}_${init_JST_cycle:8:2}00
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
