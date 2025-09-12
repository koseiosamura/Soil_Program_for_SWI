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


def grib_select(input_RRA,grbs):

    parameterName   = 'Total water precipitation'
    alines          = grbs.select(parameterName=parameterName)
    gdata, lat, lon = alines[0].data()

    return lon, lat, gdata




def calculate_distance(para_valu,lon_Anal,lon_IDW,lat_Anal,lat_IDW):

    R = float(para_valu[0])


    lon_IDW, lat_IDW, lon_Anal, lat_Anal = map(np.radians, [lon_IDW, lat_IDW, lon_Anal, lat_Anal])

    
    distance = R * np.arccos(
        np.sin(lat_Anal) *
        np.sin(lat_IDW) +
        np.cos(lat_Anal) *
        np.cos(lat_IDW) *
        np.cos(lon_IDW - lon_Anal))

    return distance
