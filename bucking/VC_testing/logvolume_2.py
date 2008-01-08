#This is a function containing an algorithmic model of the Scribner log rule, 
#   board-foot log volume tables.  It outputs the Scribner log volume for an 
#   input log length and top diameter.
#
#    Annotation:     [v]=logvolume(L,TD)
#                   v = Scribner log volume
#                   L = log length
#                   TD = top diameter

import sys

volume_table_1 = [1.07,4.9,6.043,7.14,8.88,10.0,11.528,13.29,14.99,17.499,18.99,20.88,23.51,25.218,28.677,31.249,34.22,36.376,38.04,41.06,44.376,45.975] 
volume_table_2 = [1.160,1.400,1.501,2.084,3.126,3.749 , 1.249,1.608,1.854,2.410,3.542,4.167 , 1.57,1.8,2.2,2.9,3.815,4.499] 

def logvolume_2(L,TD):
    L = L - (0.8333)	#Account for 10 inch over cut

    if TD < 5:
        L = 0  # makes v = 0 in the output
        print "Top diameter reached:", TD
        TD = 11 # handles out-of-bounds errors
        print "Error! Top diameter minimum limit of 5 inches."
    elif TD >= 32:
        print 'Error! %3.1f inch top diameter exceeds the current 32.0 inch program capability.\n' %TD 
        L = 0 
        TD = 11
    elif L > 40:
        print "Log length reached:", L
        L = 0 
        print 'Error! Maximum log length is 40 feet.'
    elif L < 1:
        print "Log length reached:", L
        L = 0 
        print 'Error! Minimum log length is 16 feet.'


    if (TD >= 6) & (TD <= 11):
        TD = TD - 6             # normalize TD with 6 for array indexing
        if L < 16:
            v = 10 * round((L * volume_table_2[TD]) / 10.0)
        elif L < 31:
            v = 10 * round((L * volume_table_2[TD + 6]) / 10.0) 
        elif L < 41:
            v = 10 * round((L * volume_table_2[TD + 12]) / 10.0) 
        else:
            v = 0
    else:
        if TD == 5:
            v = 10 * round((L * volume_table_1[0]) / 10.0) 
        else:
            v = 10 * round((L * volume_table_1[TD - 11]) / 10.0) 

    return v


def debug_logvolume():
    print
    v = logvolume_2(input("length: "),input("topdia: "))
    print "volume is:", v


