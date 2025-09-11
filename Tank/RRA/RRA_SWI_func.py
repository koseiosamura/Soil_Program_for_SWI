import numpy as np
#from numba import njit






#@njit
def first_function(SWI_index,read_SWI,read_First,RRA_where,parameter,First_list,First_arr,num):
    
    #First_list = []
    First_Z_list     = []
    First_cycle_list = []

    pre = RRA_where[:] * parameter[11]
    #print(pre)
    if num == 1:
        for i in range(SWI_index):
        
            if read_SWI[i,2] < 0:
                S1 = -9999
                Z1 = 0
            else:
                if read_First[i,2] <= parameter[0]:
                    Q12 = 0
                    Q11 = 0
                elif parameter[0] < read_First[i,2] <= parameter[1]:
                    Q12 = 0
                    Q11 = parameter[3] * (read_First[i,2] - parameter[0])
                elif parameter[0] < read_First[i,2]:
                    Q12 = parameter[4] * (read_First[i,2] - parameter[1])
                    Q11 = parameter[3] * (read_First[i,2] - parameter[0])


                Q_sum = Q11 + Q12
                if Q_sum < 0:
                    Q_F = 0
                elif Q_sum >= 0:
                    Q_F = Q_sum * parameter[11]

                Z1 = parameter[2] * read_First[i,2] * parameter[11]
                #First_Z_list.append(Z1)

                S1 = read_First[i,2] - (Q_F + Z1) + pre[i]
            First_Z_list.append(Z1)
            First_list.append(S1)
        
    else:
        for i in range(SWI_index):
            if read_SWI[i,2] < 0:
                S1 = -9999
                Z1 = 0
            else:
                if First_arr[i] <= parameter[0]:
                    Q12 = 0
                    Q11 = 0
                elif parameter[0] < First_arr[i] <= parameter[1]:
                    Q12 = 0
                    Q11 = parameter[3] * (First_arr[i] - parameter[0])
                elif parameter[0] < First_list[i]:
                    Q12 = parameter[4] * (First_arr[i] - parameter[1])
                    Q11 = parameter[3] * (First_arr[i] - parameter[0])

                Q_sum = Q11 + Q12
                if Q_sum < 0:
                    Q_F = 0
                elif Q_sum >= 0:
                    Q_F = Q_sum * parameter[11]

                Z1 = parameter[2] * First_arr[i] * parameter[11]
                #First_Z_list.append(Z1)

                S1 = First_arr[i] - (Q_F + Z1) + pre[i]
            First_Z_list.append(Z1)
            First_cycle_list.append(S1)
        
        #First_list = []
        First_list = np.array(First_cycle_list[:])

    return First_list, First_Z_list




def second_function(SWI_index,read_SWI,read_Second,parameter,First_Z,Second_list,Second_arr,num):

    Second_Z_list     = []
    Second_cycle_list = []

    if num == 1:
        for i in range(SWI_index):
            if read_SWI[i,2] < 0:
                S2  = -9999
                Z_S = 0
            else:
                if read_Second[i,2] <= parameter[5]:
                    Q2 = 0
                elif read_Second[i,2] > parameter[5]:
                    Q2 = parameter[7] * (read_Second[i,2] - parameter[5])


                if Q2 < 0:
                    Q_S = 0
                elif Q2 >= 0:
                    Q_S = Q2 * parameter[11]


                Z_S = parameter[6] * read_Second[i,2] * parameter[11]
                #Second_Z_list.append(Z_S)

                S2 = read_Second[i,2] - (Q_S + Z_S) + First_Z[i]
            Second_Z_list.append(Z_S)
            Second_list.append(S2)


    else:
        for i in range(SWI_index):
            if read_SWI[i,2] < 0:
                S2  = -9999
                Z_S = 0
            else:
                if Second_arr[i] <= parameter[5]:
                    Q2 = 0
                elif Second_arr[i] > parameter[5]:
                    Q2 = parameter[7] * (Second_arr[i] - parameter[5])

                if Q2 < 0:
                    Q_S = 0
                elif Q2 >= 0:
                    Q_S = Q2 * parameter[11]

                Z_S = parameter[6] * Second_arr[i] * parameter[11]
                #Second_Z_list.append(Z_S)

                S2 = Second_arr[i] - (Q_S + Z_S) + First_Z[i]
            Second_Z_list.append(Z_S)
            Second_cycle_list.append(S2)

        #Second_list = []
        Second_list = np.array(Second_cycle_list)


    return Second_list, Second_Z_list




def third_function(SWI_index,read_SWI,read_Third,parameter,Second_Z,Third_list,Third_arr,num):

    Third_cycle_list = []

    if num == 1:
        for i in range(SWI_index):

            if read_SWI[i,2] < 0:
                S_T = -9999
            else:
                if read_Third[i,2] <= parameter[8]:
                    Q3 = 0
                elif read_Third[i,2] > parameter[8]:
                    Q3 = parameter[10] * (read_Third[i,2] - parameter[8])

                if Q3 < 0:
                    Q_T = 0
                elif Q3 >= 0:
                    Q_T = Q3 * parameter[11]

                Z_T = parameter[9] * read_Third[i,2] * parameter[11]

                S_T = read_Third[i,2] - (Q_T + Z_T) + Second_Z[i]

            Third_list.append(S_T)

    else:
        for i in range(SWI_index):

            if Third_arr[i] < 0:
                S_T = -9999
            else:
                if Third_arr[i] <= parameter[8]:
                    Q3 = 0
                elif Third_arr[i] > parameter[8]:
                    Q3 = parameter[10] * (Third_arr[i] - parameter[8])

                if Q3 < 0:
                    Q_T = 0
                elif Q3 >= 0:
                    Q_T = Q3 * parameter[11]

                Z_T = parameter[9] * Third_arr[i] * parameter[11]

                S_T = Third_arr[i] - (Q_T + Z_T) + Second_Z[i]

            Third_cycle_list.append(S_T)

        #Third_list = []
        Third_list = np.array(Third_cycle_list)

    return Third_list
