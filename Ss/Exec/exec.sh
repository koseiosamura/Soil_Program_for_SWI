#!/bin/bash


#
#
#
#
#
#
#


set -e
. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Exec/config.sh
. /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Exec/config_common.sh

echo ""
echo "WDR=${WDR}"
echo "ENS=${IRD}"
echo "WIDR=${WIDR}"
echo "WPDR=${WPDR}"
echo "WRDR=${WRDR}"
echo "WINDR=${WINDR}"
echo "WEDR=${WEDR}"
echo ""

echo ""
echo "START DATE >>>>>> UTC : ${start_ymm}/${start_mmm}/${start_dmm} ${start_hmm}:00"
echo "END DATE   >>>>>> UTC : ${end_ymm}/${end_mmm}/${end_dmm} ${end_hmm}:00"
echo ""
echo ""
echo "---- Ensemble Member ----"
echo "( ${start_member} ***************** 0${ENS} )"
echo ""


cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. mkdir_func.sh
mkdir_WDR_function


echo "============================================================="
echo ""
echo "            Reset make Initial data for Ensemble"
echo "            "
echo "============================================================="


cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/init
. init_pre_func.sh
init_pre_function



cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. idw_SWI.sh
SWI_idw_fuction >> ${WDR}/${WDR_date}/log
echo "--- END IDW SWI"


cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/init
. init_SWI.sh
init_SWI_function
echo "--- Mep END SWI"



cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. idw_RRA.sh
RRA_idw_function >> ${WDR}/${WDR_date}/log
echo "--- END IDW RRA"


cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. cycle.sh
