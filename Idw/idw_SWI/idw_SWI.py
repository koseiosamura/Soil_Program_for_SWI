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

    IDW_SWI, x, y = IDW_netcdf(vals_SWI)
    lon, lat = np.meshgrid(x,y)
    print('')
    print(' ----------- Unzip complete -----------', flush=True)
    
    header = [np.ravel(lon), np.ravel(lat), np.ravel(IDW_SWI)]
    IDW_lonlat = np.stack(header, 1)
    
    tmpd = 'IDW_lonlat.npy'
    np.save(tmpd, IDW_lonlat)
    
    print('===============',flush=True)
    print('Nomal End ')
    print('===============',flush=True)
    

    
RAP_IDW()
