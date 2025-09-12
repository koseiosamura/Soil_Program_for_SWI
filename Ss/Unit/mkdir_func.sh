#!/bin/bash


#
#
#
#
#
#
#


mkdir_WDR_function(){

    if [ ! -d ${WDR}/${start_ymm} ]; then
        mkdir -p ${WDR}/${start_ymm}/
    fi

}


mkdir_IDW_function(){

    for IDR in RAP Ens;
    do
        if [ ! -d ${WIDR}/${IDR} ];
        then
            for IDR_cycle in netcdf data bin log;
            do
                mkdir -p ${WIDR}/${IDR}/${IDR_cycle}
            done
        fi
    done

}


mkdir_RAP_function(){

    for RAP_cycle in init Ens;
    do
	if [ ! -d ${WRDR}/${RAP_cycle} ];
	then
	    mkdir -p ${WRDR}/${RAP_cycle}
	fi
    done

}


mkdir_init_function(){

    for init_cycle in npy init;
    do
	for init_SWI_cycle in SWI First Second Third;
	do
	    if [ ! -d ${WINDR}/${init_cycle}/${init_SWI_cycle} ];
	    then
		mkdir -p ${WINDR}/${init_cycle}/${init_SWI_cycle}
	    fi
	done
    done

}


mkdir_para_function(){

    if [ ! -d ${WPDR} ];
    then
	mkdir -p ${WPDR}
    fi
	
}


mkdir_ensemble_function(){

    
    for SWI_cycle in SWI First Second Third;
    do
	for ens_member in `seq -w 001 ${end_member}`
	do
	    if [ ! -d ${WEDR}/${SWI_cycle}/${ens_member} ];
	    then
		mkdir -p ${WEDR}/${SWI_cycle}/${ens_member}
	    fi
	done
	if [ ! -d ${WEDR}/${SWI_cycle}/RAP ];
	then
	    mkdir -p ${WEDR}/${SWI_cycle}/RAP
	fi
    done

}
