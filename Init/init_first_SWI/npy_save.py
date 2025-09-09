import numpy as np



#
#
#
#
#
#
#


def npy_save_function(read_SWI,SWI,First,Second,Third,First_list,Second_list,Third_list,vals):


    data_list = [SWI, First, Second, Third]
    data_name = ['SWI', 'First', 'Second', 'Third']

    for i in range(4):
        
        header = [np.ravel(read_SWI[:,0]), np.ravel(read_SWI[:,1]), np.ravel(data_list[i])]
        stack = np.stack(header, 1)
        #condition = (stack[:,2] < int(vals[8])) & (int(vals[9]) < stack[:,2]) 
        #where = np.where(condition, -9999, stack)
        tmpd =f'{data_name[i]}_anal_{vals[6]}{vals[7]}{vals[8]}{vals[9]}00.npy'
        np.save(tmpd, stack)


