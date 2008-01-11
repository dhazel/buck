#Interpolation function  [yu]=interpolate(ux,x,y)
#This function finds a y value corresponding with a user entered x value
#The function bases its calculations on entered vectors of x and y values
#     [yu]=interpolate(ux,x,y)
#       
#       x= vector of x values
#       y= vector of y values
#       ux= user entered x value
#       yu= the interpolated y value corresponding to the user x entry
#
#Inputs must be of type float!!

def interpolate(ux,x,y):
    j = 0 
    T = 0
    n = len(x) - 1 
    if ux == x[n]:                  #check endpoint of input vector
       yu = y[n] 
    else:
        while x[j] <= ux:           #run up to the vector point above and
                T = x[j]            #   nearest to the user value.
                j = j+1 
                if j == len(x):
                    print "interpolator: ERROR - ",j," out of range in ",x,", searching for ",ux

        if T != ux:
                yu = ((y[j]-y[j-1])/(x[j]-x[j-1]))*ux-((y[j]-y[j-1])/(x[j]-x[j-1]))*x[j-1]+y[j-1] 
        else:
                yu=y[j-1] 

    return yu


def debug_interpolate():
    print
    given_x = input("given x: ")
    given_y = input("given y: ")
    elem_location = 0
    for element in given_x:
        element = float(element)
        given_x[elem_location] = element
        elem_location = elem_location + 1
    elem_location = 0
    for element in given_y:
        element = float(element)
        given_y[elem_location] = element
        elem_location = elem_location + 1
    yu = interpolate(float(input("user x: ")),given_x,given_y)
    print "user y is:", yu

