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

init_SWI_function(){

    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . date_func.sh
    init_date_function

    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . mkdir_func.sh
    mkdir_init_function

    echo ""
    echo ""
    echo "==============================="
    echo "        START INIT SWI"
    echo "==============================="
    echo "--- Mep Start"

    #init_numerical_SWI_function
    init_numerical_SWI_function >> ${WDR}/${WDR_date}/log

}



init_numerical_SWI_function(){

    init_first_unix=${start_init_unix}
    #day=1
    while [ ${init_first_unix} -le ${end_init_unix} ];
    do
	
	current_init_unix=$((${init_first_unix} - ${timedelta}))
	current_init_date=$(date -d "@$current_init_unix" "+%Y%m%d%H%M%S")
	anal_init_unix=${init_first_unix}
	anal_init_date=$(date -d "@$anal_init_unix" "+%Y%m%d%H%M%S")
	init_RAP_npy_date=${anal_init_date:0:4}${anal_init_date:4:2}${anal_init_date:6:2}${anal_init_date:8:2}00
	init_RAP_npy=${WRDR}/init/npy/init_RAP_${init_RAP_npy_date}.npy
	init_output_SWI_date=${current_init_date:0:4}${current_init_date:4:2}${current_init_date:6:2}${current_init_date:8:2}00
	if [ ! -s ${init_RAP_npy} ];
	then
	    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            echo "  CANNOT find ${init_RAP_npy}"
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            exit
        fi
	if [ ${start_init_unix} -eq ${anal_init_unix} ];
	then
	    echo ""
            echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
            echo "Maked Initial Data for 2 week ago "
            echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	    echo "### Start SWI ###"
	    first_init_SWI_function ${IDW_SWI_data}
	    echo "   --- maked first data ---"
	    #echo "       --- DAY ${day} complete "
	fi
	init_TANK_function >> ${WDR}/${WDR_date}/log
	#echo "     --- DAY ${day} complete ---"
	init_first_unix=$(($init_first_unix + ${timedelta}))
	#day=$(($day + 1))
    done
    echo "### End SWI ###"
}



first_init_SWI_function(){
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . mkdir_func.sh
    mkdir_para_function
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Parm
    eval $(python3 setting.py)
    log_para_function
    python3 make_parameter.py
    mv ${Parameter_file} ${WDR}/${start_ymm}/para
    export init_RAP_npy=${init_RAP_npy}
    export IDW_SWI_data=$1
    export lon_min=${lon_min} 
    export lon_max=${lon_max} 
    export lat_min=${lat_min} 
    export lat_max=${lat_max}
    export init_output_SWI_date=${init_output_SWI_date}
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Init/init_first_SWI
    python3 init_first_SWI.py
    for init_SWI_cycle in SWI First Second Third;
    do
	mv ${init_SWI_cycle}_anal_${init_output_SWI_date}.npy ${WINDR}/init/${init_SWI_cycle}
    done

}


init_TANK_function(){
    
    if [ ${start_init_unix} -eq ${anal_init_unix} ];
    then
	for init_SWI_cycle in SWI First Second Third;
	do
	    local varname=init_${init_SWI_cycle}_data
	    local init_SWI_valus=${WINDR}/init/${init_SWI_cycle}/${init_SWI_cycle}_anal_${init_output_SWI_date}.npy
	    if [ ! -s ${init_data_valus} ];
	    then
		echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		echo "  CANNOT find ${init_data_valus}"
		echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		exit
	    fi
	    local ${varname}=${init_SWI_valus}
	    export ${varname}
	done
    else
	for init_SWI_cycle in SWI First Second Third;
        do
	    local varname=init_${init_SWI_cycle}_data
            local init_SWI_valus=${WINDR}/npy/${init_SWI_cycle}/${init_SWI_cycle}_anal_${init_output_SWI_date}.npy
            if [ ! -s ${init_SWI_valus} ];
            then
                echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                echo "  CANNOT find ${init_data_valus}"
                echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                exit
            fi
	    local ${varname}=${init_SWI_valus}
            export ${varname}
	done
    fi
    local Para_data=${WPDR}/${Parameter_file}
    if [ ! -s ${Para_data} ];
    then
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${Para_data}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Tank/init_SWI
    export init_RAP_npy=${init_RAP_npy}
    export parameter=${Para_data}
    export init_output_SWI_anal=${init_RAP_npy_date}
    python3 init_SWI.py
    for init_SWI_cycle in SWI First Second Third;
    do
        mv ${init_SWI_cycle}_anal_${init_output_SWI_anal}.npy ${WINDR}/npy/${init_SWI_cycle}
    done

}



log_para_function(){

    cat <<EOF> ${WPDR}/parameter.txt

********************** Parameter List **********************

                      --- TANK 1 ---

L11 = ${L11}    Granite  @JMA ordinal parameter 
L12 = ${L12}    Granite  @JMA ordinal parameter
b1 = ${b1}      Granite  @JMA ordinal parameter
a11 = ${a11}    Granite  @JMA ordinal parameter
a12 = ${a12}    Granite  @JMA ordinal parameter


                      --- TANK 2 ---

L2 = ${L2}      Granite  @JMA ordinal parameter
b2 = ${b2}      Granite  @JMA ordinal parameter
a2 = ${a2}      Granite  @JMA ordinal parameter


                      --- TANK 3 ---

L3 = ${L3}      Granite  @JMA ordinal parameter
b3 = ${b3}      Granite  @JMA ordinal parameter
a3 = ${a3}      Granite  @JMA ordinal parameter


Time_delta = ${delta}

EOF

}
