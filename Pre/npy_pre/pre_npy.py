import numpy as np
import sys
import os


#
#
#
#
#
#



def init_pre_npy_main():
    
    keys = [
        "output_bin", 
        "lon_interval", 
        "lat_interval",
        "n_lon", 
        "n_lat", 
        "RAP_lon_max", 
        "RAP_lat_max", 
        "pre_level",
        "output_RAP_date"
    ]
    vals = [os.environ[k] for k in keys]
        
    data_name  = vals[0]
    data       = np.fromfile(data_name, dtype=np.int16)
    data_where = np.nan_to_num(data, nan=-1)
    data_corr  = data_where * float(vals[7])

    index     = len(data_where)
    index_sum = int(vals[3]) * int(vals[4])
    
    if index != index_sum:
        print('')
        print(' ******************* data size is not match *******************')
        print(f'   bin data size : {index_sum}    data size : {index}')
        sys.exit()
    
    
    x = np.round(float(vals[5]) - (float(vals[1]) * 0.5) + float(vals[1]) * np.arange(int(vals[3])), 5)
    y = np.round(float(vals[6]) - (float(vals[2]) * 0.5) - float(vals[2]) * np.arange(int(vals[4])), 2)
    
    lon, lat = np.meshgrid(x, y)
    
    data    = data_corr.reshape(int(vals[4]), int(vals[3]))
    lat_sw  = lat[::-1,:]
    data_sw = data[::-1,:]
    header  = [np.ravel(lon), np.ravel(lat_sw), np.ravel(data_sw)]
    stack   = np.stack(header, 1)
    tmpd    = f'RAP_{vals[8]}'
    np.save(tmpd, stack)


init_pre_npy_main()
