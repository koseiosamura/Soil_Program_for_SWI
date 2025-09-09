import numpy as np
import os
import sys
from init_SWI_func import first_function, second_function, third_function
from npy_save import npy_save_function 

#
#
#
#
#
#
#


def init_SWI():

    SWI_keys = ['init_SWI_data', 'init_First_data', 'init_Second_data', 'init_Third_data']
    SWI_valu = [os.environ[Sk] for Sk in SWI_keys]
    print(SWI_valu)

    para_keys = 'parameter'
    para_valu = os.environ[para_keys]

    RAP_keys = 'init_RAP_npy'
    RAP_valu = os.environ[RAP_keys]
    print(RAP_valu)

    output_date_keys = 'init_output_SWI_anal'
    output_date_valu = os.environ[output_date_keys]
    
    
    read_SWI    = np.load(SWI_valu[0])
    read_First  = np.load(SWI_valu[1])
    read_Second = np.load(SWI_valu[2])
    read_Third  = np.load(SWI_valu[3])
    read_RAP    = np.load(RAP_valu)
    parameter   = np.load(para_valu)
    
    
    SWI_lon_min = min(read_SWI[:,0])
    SWI_lon_max = max(read_SWI[:,0])
    SWI_lat_min = min(read_SWI[:,1])
    SWI_lat_max = max(read_SWI[:,1])
    RAP_range   = read_RAP[
        (SWI_lon_min <= read_RAP[:,0]) &  
        (read_RAP[:,0] <= SWI_lon_max) & 
        (SWI_lat_min <= read_RAP[:,1]) & 
        (read_RAP[:,1] <= SWI_lat_max)
    ]
    RAP_where = np.where(RAP_range[:,2] < 0, 0, RAP_range[:,2])
    
    
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

        First_list, First_Z_list = first_function(SWI_index, read_SWI, read_First, RAP_where, parameter, First_list, First_arr, num)
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
