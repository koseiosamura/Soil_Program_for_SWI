import numpy as np
import xarray as xr
import itertools

#
#
#
#
#
#
#
#




def IDW_netcdf(input_data):

    nc = xr.open_dataset(input_data)
    x = nc.variables['longitude'].values
    
    valus_x = 0.03125
    arr_x = np.array(x)
    x_val = arr_x - valus_x
    
    y = nc.variables['latitude'].values
    valus_y = 0.025
    arr_y = np.array(y)
    y_val = arr_y - valus_y
    
    grib_data = nc.variables['var0_1_206_localleveltype200'].values[0,:,:]
    d2_list = list(itertools.chain.from_iterable(grib_data))
    arr = np.array(d2_list)
    IDW_SWI = np.nan_to_num(arr, nan=-9999)
    

    return IDW_SWI, x_val, y_val


