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

. ./cycle_func.sh


cd  /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. mkdir_func.sh
mkdir_ensemble_function


cd /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Unit
. date_func.sh
date_function


cycle_function
