import numpy as np

from setting import L11, L12, b1, a11, a12, L2, b2, a2, L3, b3, a3, delta


#
#
#
#
#
#




def make_parameter_function():
    
    
    parameters_npy = np.array([
         L11,
         L12,
         b1,
         a11,
         a12,
         L2,
         b2,
         a2,
         L3,
         b3,
         a3,
         delta
    ])


    np.save('parameter.npy', parameters_npy)


make_parameter_function()
