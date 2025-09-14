import numpy as np
import pygrib


#
#
#
#
#
#
#
#


def RRA_grib(input_RRA_data):
    
    grbs = pygrib.open(input_RRA_data)
    parameterName   = 'Total water precipitation'
    alines          = grbs.select(parameterName=parameterName)
    gdata, lat, lon = alines[0].data()

    return lon, lat, gdata



def num_IDW_RRA(read_SWI_IDW,read_RRA_IDW,index_SWI,IDW_RRA_list,key_indices,RRA_dict):
    for i in range(0,index_SWI):
        weight_data_list = []
        #print(i)
        if read_SWI_IDW[i,2] < 0:
            IDW_RRA = -1
            IDW_RRA_list.append(IDW_RRA)
        else:
            for lon_indi, lat_indi in key_indices:
                key = (read_RRA_IDW[i,lon_indi], read_RRA_IDW[i,lat_indi])
                weight_data = RRA_dict.get(key, None)
                weight_data_list.append(weight_data[2])

            if weight_data is None:
                print(' @@@@@@@@@@@@ No weight data @@@@@@@@@@@@')
                sys.exit()

            IDW_RRA = weight_pre(weight_data_list,read_RRA_IDW,i)
            IDW_RRA_list.append(IDW_RRA)

    
    return IDW_RRA_list



def weight_pre(weight_data_list,read_RRA_IDW,i):

    d1 = 1 / (read_RRA_IDW[i,2] ** 2)
    d2 = 1 / (read_RRA_IDW[i,5] ** 2)
    d3 = 1 / (read_RRA_IDW[i,8] ** 2)
    d4 = 1 / (read_RRA_IDW[i,11] ** 2)

    w1 = weight_data_list[0]
    w2 = weight_data_list[1]
    w3 = weight_data_list[2]
    w4 = weight_data_list[3]

    W_upper = (d1 * w1) + (d2 * w2) + (d3 * w3) + (d4 * w4)
    W_low = d1 + d2 + d3 + d4

    weight = W_upper / W_low


    return weight



