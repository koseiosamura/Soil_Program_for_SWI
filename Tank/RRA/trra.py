import numpy as np
import os


from trra_func import RRA_grib, num_IDW_RRA, weight_pre



#
#
#
#
#
#
#
#



def main_trra():
    
    keys = ['RRA_data', 'IDW_RRA_data', 'IDW_SWI_data']
    vals = [os.environ[k] for k in keys]
    
    
    input_SWI_IDW = vals[2]
    read_SWI_IDW  = np.load(input_SWI_IDW)
    print(read_SWI_IDW)

    input_RRA_IDW = vals[1]
    read_RRA_IDW  = np.load(input_RRA_IDW) 
    print(read_RRA_IDW)

    input_RRA_data  = vals[0]
    lon, lat, gdata = RRA_grib(input_RRA_data)
    

    RRA_header    = [np.ravel(lon), np.ravel(lat), np.ravel(gdata)]
    RRA_arr       = np.stack(RRA_header, 1)
    RRA_arr_range = RRA_arr[
        (min(read_SWI_IDW[:,0]-1) <= RRA_arr[:,0]) & 
        (RRA_arr[:,0] <= max(read_SWI_IDW[:,0]+1)) & 
        (min(read_SWI_IDW[:,1]-1) <= RRA_arr[:,1]) & 
        (RRA_arr[:,1] <= max(read_SWI_IDW[:,1]+1))
    ]
    #print(RRA_arr_range)


    #input_IDW_data = '/mnt/hail8/nakaya/Soil_program/calculation_test/result/Work/ctrltest/2020/IDW/data/IDW_dis.npy'
    #read_IDW = np.load(input_IDW_data)
    


    #input_init_data = '/mnt/hail8/nakaya/Soil_program/calculation_test/result/Work/ctrltest/2020/Init/data/initial_SWI.npy'
    #read_init = np.load(input_init_data)
    
    index_SWI = len(read_SWI_IDW)


    RRA_dict = {
        (lon, lat): row
        for row in RRA_arr_range
        for lon, lat in [tuple(row[:2])]
    }


    key_indices = [(0,1),(3,4),(6,7),(9,10)]
    IDW_RRA_list = []

    
    IDW_RRA_list = num_IDW_RRA(read_SWI_IDW,read_RRA_IDW,index_SWI,IDW_RRA_list,key_indices,RRA_dict)


    IDW_RRA_array = np.array(IDW_RRA_list)
    IDW_RRA_where = np.where((0 < IDW_RRA_array) & (IDW_RRA_array < 0.4), 0, IDW_RRA_array)
    print(len(IDW_RRA_where))
    tmpd = f'RRA_anal_{vals[5]}00.npy'
    np.save(tmpd, IDW_RRA_where)
    
        


main_trra()
    




