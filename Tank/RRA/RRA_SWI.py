import numpy as np
import os
import sys
from RRA_SWI_func import first_function, second_function, third_function
from npy_save import npy_save_function 

#
#
#
#
#
#
#


def init_SWI():

    SWI_keys = ['SWI_data', 'First_data', 'Second_data', 'Third_data']
    SWI_valu = [os.environ[Sk] for Sk in SWI_keys]
    print(SWI_valu)

    para_keys = 'parameter'
    para_valu = os.environ[para_keys]

    RRA_keys = 'RRA_npy'
    RRA_valu = os.environ[RRA_keys]
    print(RRA_valu)

    output_date_keys = 'output_Ens_date'
    output_date_valu = os.environ[output_date_keys]
    print(output_date_valu)
    
    read_SWI    = np.load(SWI_valu[0])
    read_First  = np.load(SWI_valu[1])
    read_Second = np.load(SWI_valu[2])
    read_Third  = np.load(SWI_valu[3])
    read_RRA    = np.load(RRA_valu)
    parameter   = np.load(para_valu)
    
    '''
    SWI_lon_min = min(read_SWI[:,0])
    SWI_lon_max = max(read_SWI[:,0])
    SWI_lat_min = min(read_SWI[:,1])
    SWI_lat_max = max(read_SWI[:,1])
    RRA_range   = read_RRA[
        (SWI_lon_min <= read_RRA[:,0]) &  
        (read_RRA[:,0] <= SWI_lon_max) & 
        (SWI_lat_min <= read_RRA[:,1]) & 
        (read_RRA[:,1] <= SWI_lat_max)
    ]
    '''
    RRA_where = np.where(read_RRA[:] < 0, 0, read_RRA[:])
    print(RRA_where)
    
    
    SWI_index = len(read_SWI)

    
    num = 1
    First_list  = []
    Second_list = []
    Third_list  = []
    First_arr   = []
    Second_arr  = []
    Third_arr   = []
    while num <= 6:
        print(f' ---- mep {num}0',flush=True)

        First_list, First_Z_list = first_function(SWI_index, read_SWI, read_First, RRA_where, parameter, First_list, First_arr, num)
        First_arr = np.array(First_list[:])

        First_Z = np.array(First_Z_list[:])
        Second_list, Second_Z_list = second_function(SWI_index,read_SWI,read_Second,parameter,First_Z,Second_list,Second_arr,num)
        Second_arr = np.array(Second_list[:])

        Second_Z   = np.array(Second_Z_list[:])
        Third_list = third_function(SWI_index,read_SWI,read_Third,parameter,Second_Z,Third_list,Third_arr,num)
        Third_arr  = np.array(Third_list[:])

        num +=1
    
    
    SWI    = First_arr + Second_arr + Third_arr
    First  = First_list
    Second = Second_list
    Third  = Third_list
    

    npy_save_function(read_SWI,SWI,First,Second,Third,output_date_valu)


init_SWI()
