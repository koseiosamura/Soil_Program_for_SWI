#!/bin/bash


#=================================================================
#
#
#
#
#=================================================================


#---------------------------
# 0. setting date
#---------------------------
. config.sh


#---------------------------
# 1. Ensemble setting
#---------------------------
ENS=31                # Ensemble member (Ensemble + ctrl)
start_member=001      # Ensemble Start member name
end_member=0${ENS}    # End Ensemble
ctrl_member=031       # ctrl member name
kind=sfc              # kind (sfc, cnst)
cond_kind=fcst        # Ensemble condition (fcst, anl)
RRA_ext=grib2         # Ensemble data format



#---------------------------
# 2, timedelta setting
#---------------------------
readonly timedelta=3600    # timedelta (s) 
readonly init_timeday=14   # make initial SWI (d)
readonly init_timehour=24  # initial timedelta for hour (h)
readonly timehour=24       # timedelta for hour (h)
readonly delta=10          # numerical cycle (m), fixed 10min [10=10min, 60=1hour]



#---------------------------
# 3. raid setting
#---------------------------
raid_dir=/mnt/hail8/nakaya       # raid directory
EDR=/mnt/jet11/osamura/Ensemble  # Ensemble directory
RDR=/mnt/jet11/osamura/RAP       # RAP directory



#---------------------------
# 4. directory setting
#---------------------------
WDR=${raid_dir}/Soil_program/calculation_Soil/result/Work/Ensemble   # Work directory
WDR_LETKF=${start_ymm}${start_mmm}${start_dmm}${start_hmm}00         # Work Start Ensemble directory
WDR_date=${start_ymm}/${WDR_LETKF}                                   # Work Start Ensemble date directory
WIDR=${WDR}/${start_ymm}/IDW                                         # Work IDW directory
WPDR=${WDR}/${start_ymm}/para                                        # Work parameter directory
WRDR=${WDR}/${WDR_date}/Pre                                          # Work Precipiation directory
WINDR=${WDR}/${WDR_date}/init                                        # Work Initial directory
WEDR=${WDR}/${WDR_date}/SWI                                          # Work SWI Ensemble directory

IDW_file=Z__C_RJTD_20200703180000_SRF_GPV_Gll5km_Psw_ANAL_grib2.bin  # IDW base file
IRD=${EDR}/${WDR_date}/${kind}                                       # Ensmeble date directory
IDW_RRA_grib=${cond_kind}_${kind}_199808010100.${RRA_ext}            # IDW RRA base file



#--------------------------------
# 5. IDW, para, init data file
#--------------------------------
init_first_file=initial_SWI.npy    # output init file
IDW_SWI_file=IDW_lonlat.npy        # output IDW SWI file
IDW_RRA_file=IDW_RRA_dis.npy       # output IDW RRA file
Parameter_file=parameter.npy       # output parameter file



#---------------------------
# 6. error data
#---------------------------
min_where=-1000         # eorro max
max_where=1000          # error min




#---------------------------
# 7. JAM Rainfall setting
#---------------------------
readonly JMA_Rader=J    # JMA RAP [J: Japan, O; Okinawa]

#----------- J range
if [ "${JMA_Rader}" = "J" ];
then
    dx=5                   # grid interval for x km
    dy=5                   # grid interval for y km
    lon_interval=0.0625    # grid interval for lon
    lat_interval=0.05      # grid interval for lat
    n_lon=352              # x grid value
    n_lat=440              # y grid value
    pre_level=0.1          # precipitation level, fixed 0.1
    RAP_lon_max=125.53125  # lon max
    RAP_lat_max=46.975     # lat max
    IDW_level=1            # IDW level 

#------------ O range
elif ["${JMA_Rader}" = "O" ];
then
    dx=5
    dy=5
    lon_interval=0.0625
    lat_interval=0.05
    n_lon=352
    n_lat=440
    pre_level=0.1
    RAP_lon_max=125.53125
    RAP_lat_max=46.975
    IDW_level=1
fi


SWI_lon_min=118
SWI_lon_max=150
SWI_lat_min=20
SWI_lat_max=48
SWI_lon_step=0.0625
SWI_lat_step=0.05
lon_size=512
lat_size=560



#---------------------------
# 8. numerical range
#---------------------------
lon_min=137.36    # range lon min
lon_max=140.13    # range lon max
lat_min=36.85     # range lat min
lat_max=38.55     # range lat max



#---------------------------
# 9. Log 
#---------------------------
Log_cycleUnzip="10 --- Unzip"     
Log_cycleInit="15 --- Init"       
Log_cycleRRA="20 --- Ensemble"
Log_cycleRAP="30 --- RAP"




#---------------------------
# 10. IDW parameter
#---------------------------
readonly data_ext=RAP
R=6371.1        # earth
k=4             # minimum number parameter
