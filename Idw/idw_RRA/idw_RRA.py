import numpy as np
import os
import pygrib
from datetime import datetime

from idw_func import grib_select, calculate_distance


###############################################################################################
#   
#      
#
#
#
#
#
###############################################################################################


def main_idw_RRA():

    #print('============================',flush=True)
    #print('         Start IDW ',flush=True)
    #print('============================',flush=True)
    #print('',flush=True)


    keys_data = ['IDW_RRA_bin', 'IDW_SWI']
    data_valu = [os.environ[kd] for kd in keys_data]
    
    keys_para = ['R', 'k']
    para_valu = [os.environ[kp] for kp in keys_para]
    
    keys_output = 'IDW_RRA_file'
    output_valu = os.environ[keys_output]


    dis_lonlat = []

    
    input_data = data_valu[1]
    input_RRA  = data_valu[0]

    print('************ GRIB DATA NAME ************',flush=True)
    grbs = pygrib.open(input_RRA)
    for grb in grbs:
        print(grb.name, flush=True)
    print('****************************************',flush=True)
    #print('',flush=True)

    lon, lat, gdata = grib_select(input_RRA,grbs)
    

    header     = [np.ravel(lon), np.ravel(lat), np.ravel(gdata)]
    RRA_lonlat = np.stack(header, 1)
    

    read_SWI = np.load(input_data)
        
    
    RRA_index = len(RRA_lonlat)
    SWI_index = len(read_SWI)
        
    
    print(f'START SWI_Cycle  {SWI_index}',flush=True)
    print(f'START RAP_Cycle  {RRA_index}',flush=True)
    print('',flush=True)
    print('RANGE SWI_Cycle  ',min(read_SWI[:,0]),'-',max(read_SWI[:,0]),' ',min(read_SWI[:,1]),'-',max(read_SWI[:,1]))
    print('RANGE RAP_Cycle  ',min(RRA_lonlat[:,0]),'-',max(RRA_lonlat[:,0]),' ',min(RRA_lonlat[:,1]),'-',max(RRA_lonlat[:,1]))
    print('',flush=True)
    

    now = datetime.now()
    #print('---------- Start calculation distance for IDW  -----------',flush=True)
    #print(f'       Start time : {now}',flush=True)
    #print('----------------------------------------------------------',flush=True)


    n = 1
    step_float  = np.arange(0,SWI_index,(SWI_index)/20)
    step_arange = step_float.astype(np.int32)
    
    for i in range(0,SWI_index):
        
        
        if i in step_arange:
            print(f'   ---- step complete ({n}) ----',flush=True)
            n += 1
            
        if read_SWI[i,2] < 0:
            arr = np.zeros(RRA_index)
        else:
            lat_Anal = np.full(RRA_index,read_SWI[i,1])
            lon_Anal = np.full(RRA_index,read_SWI[i,0])
            

            lat_IDW = np.array(RRA_lonlat[:,1])
            lon_IDW = np.array(RRA_lonlat[:,0])
            
            arr = np.round(calculate_distance(para_valu,lon_Anal,lon_IDW,lat_Anal,lat_IDW), 6)


                
        k = int(para_valu[1])
        small = np.argpartition(arr, k-1)[:k]
        

        for small_index in small:

            dis_lonlat.append(RRA_lonlat[small_index,0])
            dis_lonlat.append(RRA_lonlat[small_index,1])
            dis_lonlat.append(arr[small_index])


    small_index_size = len(dis_lonlat)
    size = [int(small_index_size / 12), 12]
    V    = np.array(dis_lonlat).reshape(size).tolist()
    

    tmpd = f'{output_valu}'
    np.save(tmpd, V)



    now_end = datetime.now()
    #print('',flush=True)
    #print('============================',flush=True)
    #print('        Nomal End IDW ',flush=True)
    #print('============================',flush=True)
    #print(f'{now_end}',flush=True)


main_idw_RRA()
