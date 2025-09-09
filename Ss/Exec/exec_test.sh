#!/bin/bash


#============================================================================
#
#
#
#
#============================================================================

set -e
. config.sh
. config_common.sh




#mkdir_WDR_function(){
    
#    if [ ! -d ${WDR}/${start_ymm} ]; then
#	mkdir -p ${WDR}/${start_ymm}/
#    else
#	echo ""
#	echo " ************ Exist ${WDR}/${start_ymm}"
#    fi

#}


#mkdir_IDW_function(){

#    IDW_dir=${WDR}/${start_ymm}/IDW
#    for IDR in RAP Ens;
#    do
#	if [ ! -d ${IDW_dir}/${IDR} ];
#	then
#	    for IDR_cycle in netcdf data bin;
#	    do 
#		mkdir -p ${IDW_dir}/${IDR}/${IDR_cycle}
#	    done
#	else
	    #echo ""
#	    echo " ************ Exists ${IDW_fir}/${IDR} directory"
#	fi
#    done

#}


#mkdir_RAP_function(){
#
#
#}

cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. mkdir_func.sh

mkdir_WDR_function

mkdir_IDW_function

break




netcdf_init_function(){

    readonly init_SWI_data=${init_SWI_date}/Z__C_RJTD_${start_ymm}${start_mmm}${start_dmm}${start_hmm}0000_SRF_GPV_Ggis1km_Psw_Aper10min_ANAL_grib2.bin


    for i in $(seq 1 3); do
	if [ ${i} -eq 1 ]; then
	    CDF=${init_SWI_data}_SWI.nc
	fi
	
	if [ ${i} -eq 2 ]; then
	    CDF=${init_SWI_data}_first.nc
	fi
	
	if [ ${i} -eq 3 ]; then
	    CDF=${init_SWI_data}_second.nc
	fi
		
	wgrib2 ${init_SWI_data} -d 1.${i} -netcdf ${CDF}
    done
    echo ""

}



netcdf_IDW_function(){

    IDW_RAP_date=${RAP_dir}/${start_ymm}${start_mmm}/${start_ymm}${start_mmm}${start_dmm}
    IDW_RAP_data=${IDW_RAP_date}/Z__C_RJTD_${start_ymm}${start_mmm}${start_dmm}${start_hmm}0000_SRF_GPV_Ggis1km_Prr60lv_ANAL_grib2.bin    
    CDF_IDW=${IDW_RAP_data}.nc
    wgrib2 ${IDW_RAP_data} -netcdf ${CDF_IDW}

}



date_function(){
    echo ""
    echo START_DATE : ${start_ymm}/${start_mmm}/${start_dmm}/ ${start_hmm}:00
    echo END_DATE : ${end_ymm}/${end_mmm}/${end_dmm}/ ${end_hmm}:00
    echo ""

    start_date=$(printf "%04d-%02d-%02d %02d:00:00" $start_ymm $start_mmm $start_dmm $start_hmm)
    end_date=$(printf "%04d-%02d-%02d %02d:00:00" $end_ymm $end_mmm $end_dmm $end_hmm)

    start_unix=$(date -d "$start_date" +%s)
    end_unix=$(date -d "$end_date" +%s)

}





init_SWI_function(){

    init_dir=${WDR}/${start_ymm}/Init
    for dir in data log netcdf; do
	if [ ! -d ${init_dir}/${dir} ]; then
	    mkdir -p ${init_dir}/${dir}
	else
	    echo "exist ${init_dir}/${dir}"
	fi
    done

    netcdf_init_function
    mv ${init_SWI_date}/*.nc ${init_dir}/netcdf

    shopt -s nullglob
    init_netcdf=${init_dir}/netcdf/*.nc
    
    if [ -z "${init_netcdf}" ]; then
	echo '***********  No Initial netcdf Data  ***********'
	exit 1
    fi
 
    echo "======================================================"
    echo "                 Make Initial SWI"
    echo "======================================================"
    echo " - Use prepared init : "${init_SWI_data}

    if [ ! -f ${init_SWI_data} ]; then
	echo "***********  No Initial Data  ***********"
	exit 1
    else
	echo "   Find initial data"
	echo ""
	#echo ${init_netcdf}
	vals="${init_SWI_data} ${SWI_lon_min} ${SWI_lon_max} ${SWI_lat_min} ${SWI_lat_max} ${SWI_lon_step} ${SWI_lat_step} ${lon_min} ${lon_max} ${lat_min} ${lat_max} ${lon_size} ${lat_size} ${init_file}"
	cd /mnt/hail8/nakaya/Soil_program/calculation_test/Tools/init
	#echo ${vals}
	python3 init_get.py ${vals} ${init_netcdf} >& ${WDR}/${start_ymm}/Init/log/init_log
    fi
    
    mv ${init_file} ${init_dir}/data
    
}




Inverse_Distance_Weighted_function(){

    echo ''
    echo "======================================================"
    echo "                   IDW distance"
    echo "======================================================"

    IDW_dir=${WDR}/${start_ymm}/IDW
    for dis_dir in netcdf data log; do
	if [ ! -d ${IDW_dir}/${dis_dir} ]; then
	    mkdir -p ${IDW_dir}/${dis_dir}
	else
	    echo "exist ${IDW_dir}/${dis_dir}"
	fi
    done

    netcdf_IDW_function
    mv ${CDF_IDW} ${IDW_dir}/netcdf
    if [ -z $(ls -A ${IDW_dir}/netcdf) ]; then
	echo "***********  No IDW RAP Data  ***********"
	exit 1
    fi

    cd /mnt/hail8/nakaya/Soil_program/calculation_test/Tools/IDW    
    python3 IDW.py ${IDW_dir} ${init_dir} ${start_ymm} ${start_mmm} ${start_dmm} ${start_hmm} ${R} ${k} ${IDW_file} >& ${IDW_dir}/log/IDW_log
    
    mv ${IDW_file} ${IDW_dir}/data

}


make_parameter_function(){
    parame_dir=${WDR}/${start_ymm}/para
    
    if [ ! -d ${parame_dir} ]; then
	mkdir -p ${parame_dir}
    else
	echo "exist ${parame_dir}"
    fi

    cd /mnt/hail8/nakaya/Soil_program/calculation_test/Tools/TANK/parameter_function
    python3 make_parameter.py 

    mv log_parameter.txt ${parame_dir}
    mv parameter.npy ${parame_dir}

}


mkdir_SWI_function(){

    for dir_SWI in SWI First Second Third; do
        if [ ! -d ${npy_SWI_dir}/${dir_SWI} ]; then
            mkdir -p ${npy_SWI_dir}/${dir_SWI}
        else
            echo "exist ${npy_SWI_dir}/${dir}"
        fi
    done

}


nomal_numerical_SWI_function(){

    netcdf_RAP_dir=${WDR}/${start_ymm}/RAP/netcdf
    if [ ! -d ${netcdf_RAP_dir} ]; then
	mkdir -p ${netcdf_RAP_dir}
    else
	echo "exist ${netcdf_RAP_dir}"
    fi

    npy_RAP_dir=${WDR}/${start_ymm}/RAP/npy
    if [ ! -d ${npy_RAP_dir} ]; then
	mkdir -p ${npy_RAP_dir}
    else
	echo "exist ${npy_RAP_dir}"
    fi

    make_parameter_function
    for para_file in log_parameter.txt parameter.npy; do
	if [ ! -f ${parame_dir}/${para_file} ]; then
	    echo '***********  No parameter ${para_file} Data  ***********'
	    exit 1
	fi
    done


    while [ ${start_unix} -le ${end_unix} ]; do

	anal_unix=$((start_unix + ${timedelta}))

	time_str=$(date -d "@$start_unix" "+%Y-%m-%d %H:%M:%S")
	time_anal=$(date -d "@$anal_unix" "+%Y-%m-%d %H:%M:%S")

	
	npy_SWI_dir=${WDR}/${start_ymm}/SWI/${time_anal:5:2}/${time_anal:8:2}	
	if [[ $((10#${time_anal:11:2})) -eq 0 || $((10#${time_str:5:2}${time_str:8:2}${time_str:11:2})) -eq $((10#${start_mmm}${start_dmm}${start_hmm})) ]];
	then
	    mkdir_SWI_function
	fi
	    
	
	echo ''
	echo "======================================================"
	echo "     "SWI cycle : ${delta} min
	echo "        "INIT ${time_str:0:4}/${time_str:5:2}/${time_str:8:2} ${time_str:11:2}:00
	echo "        "ANAL ${time_anal:0:4}/${time_anal:5:2}/${time_anal:8:2} ${time_anal:11:2}:00
	echo "======================================================"

	nomal_numerical_RAP_function

	echo " 3. --- Numerical"
	npy_RAP_data=${npy_RAP_dir}/RAP_anal_${time_anal:0:4}${time_anal:5:2}${time_anal:8:2}${time_anal:11:2}00.npy
	echo "Input RAP data : ${npy_RAP_data}"
	if [ ! -f ${npy_RAP_data} ];then
	    echo "***********  No IDW RAP Data  ***********"
	    exit 1
	fi

	######
	parameter_npy=${parame_dir}/parameter.npy
	
	if [ $((10#${time_str:0:4}${time_str:5:2}${time_str:8:2}${time_str:11:2})) -eq $((10#${start_ymm}${start_mmm}${start_dmm}${start_hmm})) ];
	then
	    cd /mnt/hail8/nakaya/Soil_program/calculation_test/Tools/TANK/init_numerical_function
	    python3 init_numerical_SWI.py ${npy_RAP_data} ${init_data} ${time_anal:0:4} ${time_anal:5:2} ${time_anal:8:2} ${time_anal:11:2} ${parameter_npy} ${min_where} ${max_where}
	    for data in SWI First Second Third; 
	    do
		mv ${data}_anal_${time_anal:0:4}${time_anal:5:2}${time_anal:8:2}${time_anal:11:2}00.npy ${npy_SWI_dir}/${data}
	    done
	    rm ${netcdf_RAP_dir}/${CDF_RAP}
	else
	    npy_SWI_cycle_dir=${WDR}/${time_str:0:4}/SWI/${time_str:5:2}/${time_str:8:2}
	    init_list=()
	    for cycle_data in SWI First Second Third; 
	    do
		SWI_init_data=${npy_SWI_cycle_dir}/${cycle_data}/${cycle_data}_anal_${time_str:0:4}${time_str:5:2}${time_str:8:2}${time_str:11:2}00.npy
		init_list+=("${SWI_init_data}")
	    done
	    cd /mnt/hail8/nakaya/Soil_program/calculation_test/Tools/TANK/numerical_function
	    python3 numerical_SWI.py ${npy_RAP_data} ${init_list[@]} ${time_anal:0:4} ${time_anal:5:2} ${time_anal:8:2} ${time_anal:11:2} ${parameter_npy} ${min_where} ${max_where}
	    for data in SWI First Second Third;
            do
                mv ${data}_anal_${time_anal:0:4}${time_anal:5:2}${time_anal:8:2}${time_anal:11:2}00.npy ${npy_SWI_dir}/${data}
            done
	    rm ${netcdf_RAP_dir}/${CDF_RAP}
	    
	fi
	
	start_unix=$((start_unix + ${timedelta}))
    
	
done

}


nomal_numerical_RAP_function(){
    RAP_date=${RAP_dir}/${time_anal:0:4}${time_anal:5:2}/${time_anal:0:4}${time_anal:5:2}${time_anal:8:2}
    RAP_data=${RAP_date}/Z__C_RJTD_${time_anal:0:4}${time_anal:5:2}${time_anal:8:2}${time_anal:11:2}0000_SRF_GPV_Ggis1km_Prr60lv_ANAL_grib2.bin

    netcdf_RAP_function
    mv ${CDF_RAP} ${netcdf_RAP_dir}

    echo " 1. --- Inital"
    #IDW_dir=${WDR}/${start_ymm}/IDW
    IDW_data=${IDW_dir}/data/${IDW_file}
    
    if [ ! -f ${IDW_data} ];
    then
	echo ''
	echo "***********  No IDW file  ***********"
	break
    fi

    init_data=${init_dir}/data/${init_file}
    if [ ! -f ${init_data} ]; 
    then
	echo ''
	echo '***********  No init npy data  ***********'
	break
    fi

    if [ ! -f ${RAP_data} ];
    then
        echo "***********  No RAP Data  ***********"
        break
    else
	echo " 2. --- RAP_init"
        cd /mnt/hail8/nakaya/Soil_program/calculation_test/Tools/TANK/RAP_function
        python3 IDW_RAP.py ${netcdf_RAP_dir} ${CDF_RAP} ${IDW_data} ${init_data} ${time_anal:0:4} ${time_anal:5:2} ${time_anal:8:2} ${time_anal:11:2}
    fi
    
    mv RAP_anal_${time_anal:0:4}${time_anal:5:2}${time_anal:8:2}${time_anal:11:2}00.npy ${npy_RAP_dir}
	

}


date_function

init_SWI_function

IDW_dir=${WDR}/${start_ymm}/IDW
IDW_data=${IDW_dir}/data/${IDW_file}
if [ ! -f ${IDW_data} ];
then
    Inverse_Distance_Weighted_function
else
    echo "IDW data exist"
fi


nomal_numerical_SWI_function

