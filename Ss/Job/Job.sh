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


RRA_idw_Job_function(){

    start_RRA_idw=$(date "+%Y-%m-%d %H:%M:%S")
    echo "======================================="
    echo ""
    echo "     Cycle 0"
    echo "              IDW RRA"
    echo ""
    echo "---------------------------------------"
    echo "     START : ${start_RRA_idw}"
    echo "======================================="


}


Init_check_Job_function(){

    start_init_check=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "======================================="
    echo ""
    echo "     Cycle 15"
    echo "             INIT CHECK"
    echo ""
    echo "---------------------------------------"
    echo "     START : ${start_init_check}"
    echo "======================================="

}

RAP_start_Job_function(){

    start_unzip_now=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "  Cycle 1hour"
    echo "          RAP NUMREICAL SWI"
    echo "          START : ${start_unzip_now}"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
}



ENS_start_Job_function(){

    start_RRA_now=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "======================================="
    echo ""
    echo "     Cycle 20"
    echo "       Numerical SWI [ Ensemble ]"
    echo ""
    echo "---------------------------------------"
    echo "     START : ${start_RRA_now}"
    echo "======================================="



}






End_cycle_function(){

    if [ $1 -gt $2 ];
    then
	End_cycle_date=$(date -d "@$1" "+%Y%m%d%H%M%S")
	End_now=$(date "+%Y-%m-%d %H:%M:%S")
	
	echo "=============================="
	echo "   End Cycle"
	echo ""
	echo "      ${End_cycle_date:0:12}"
	echo "      ${End_now}"
	echo ""
	echo "=============================="
	exit
    fi

}


Start_cycle_function(){

    
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "  Cycle 1hour"
    echo "     START CYCLE : ${c_yy}/${c_mm}/${c_dd}/ ${c_hh}:00"
    echo "     END CYCLE   : ${a_yy}/${a_mm}/${a_dd}/ ${a_hh}:00"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    

}
