#!/bin/bash

#PBS -q tqueue
#PBS -N exec
#PBS -l nodes=1:ppn=1
#PBS -V


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
#. config.sh

dir=/mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/Ss/Exec
cd ${dir}


#bash exec.sh >& ../../result/${start_ymm}/log_${start_ymm}${start_mmm}${start_dmm}${start_hmm}
bash exec.sh > /mnt/hail8/nakaya/Soil_program/calculation_Soil/Nhm_Ensemble_SWI/result/1998/log
