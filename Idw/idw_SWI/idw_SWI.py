import sys
import numpy as np
from datetime import datetime
import os

from idw_SWI_func import IDW_netcdf


###############################################################################################
#   
#      
#
#
#
#
#
#


def RAP_IDW():

    print('============================',flush=True)
    print('         Start IDW ')
    print('============================',flush=True)
    print('')

    keys_SWI = "IDW_netcdf" 
    vals_SWI = os.environ[keys_SWI]

    keys_range = ["lon_min", "lon_max", "lat_min", "lat_max"]
    vals_range = [os.environ[kr] for kr in keys_range]

    IDW_SWI, x, y = IDW_netcdf(vals_SWI)
    lon, lat = np.meshgrid(x,y)
    print('')
    print(' ----------- Unzip complete -----------', flush=True)
    
    header     = [np.ravel(lon), np.ravel(lat), np.ravel(IDW_SWI)]
    IDW_lonlat = np.stack(header, 1)
    IDW_range  = IDW_lonlat[
        (float(vals_range[0]) <= IDW_lonlat[:,0]) &
        (IDW_lonlat[:,0] <= float(vals_range[1])) &
        (float(vals_range[2]) <= IDW_lonlat[:,1]) &
        (IDW_lonlat[:,1] <= float(vals_range[3]))
    ]

    tmpd = 'IDW_lonlat.npy'
    np.save(tmpd, IDW_range)
    
    print('',flush=True)
    print('===============',flush=True)
    print('Nomal End ')
    print('===============',flush=True)
    

    
RAP_IDW()
