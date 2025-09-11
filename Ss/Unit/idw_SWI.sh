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


SWI_idw_fuction(){

    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
    . mkdir_func.sh
    mkdir_IDW_function
    
    if [ ${start_ymm} -le 2001 ];
    then
	IDW_5dx_function
    fi
    mv ${IDW_SWI_file} ${WIDR}/RAP/data
    IDW_SWI_data=${WIDR}/RAP/data/${IDW_SWI_file}
    if [ ! -s ${IDW_SWI_data} ];
    then
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${IDW_SWI_data}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    
}



IDW_5dx_function(){

    cp ${raid_dir}/${IDW_file} ${WIDR}/RAP/bin
    IDW_bin=${WIDR}/RAP/bin/${IDW_file}
    if [ ! -s ${IDW_bin} ];
    then
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${IDW_bin}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    idw_RAP=${WRDR}/init/npy/init_RAP_${start_ymm}${start_mmm}${start_dmm}${start_hmm}00.npy
    if [ ! -s ${idw_RAP} ];
    then
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${idw_RAP}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    unzip_SWI_bin_function
    IDW_netcdf=${WIDR}/RAP/netcdf/${IDW_file}.nc
    if [ ! -s ${IDW_netcdf} ];
    then
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "  CANNOT find ${IDW_netcdf}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        exit
    fi
    export IDW_netcdf=${IDW_netcdf}
    export lon_min=${lon_min}
    export lon_max=${lon_max}
    export lat_min=${lat_min}
    export lat_max=${lat_max}
    cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Idw/idw_SWI
    python3 idw_SWI.py > ${WIDR}/RAP/log/IDW.txt
    

}


unzip_SWI_bin_function(){

    CDF=${IDW_bin}.nc
    wgrib2 ${IDW_bin} -d 1.${IDW_level} -netcdf ${CDF}
    mv ${CDF} ${WIDR}/RAP/netcdf

}
