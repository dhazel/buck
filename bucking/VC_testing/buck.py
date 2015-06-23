#!/usr/bin/python
#
#Program-----'buck'
#This program is designed to interpolate and solve for the best buck lengths
#   at which to cut a felled tree.
#The final intent of this program is to obtain an algorythm that can fit
#   on a TI86 and run in a quick fashion with the most possible accuracy.
#This program takes in length and diameter readings from the felled tree,
#   and then maximizes buck lengths to achieve the best price.
#----------------------------
#CAPACITIES AND LIMITATIONS:
#   -Minumum diameter of 5in accepted
#   -Maximum diameter of 32in accepted
#   -Minumum length of 16ft accepted
#   -Will accept two mid-trunk taper changes
#   -Will calculate buck lengths for five logs to a tree, though this could be varied
#   -Does not calculate poles -- saw logs only, max length output of 40ft
#----------------------------
#This program is made up of the modules:
#   'buck0i' -- the interpolator
#   'buck1p' -- the price check function
#   'buck2f' -- the table feeder
#   'buck3c' -- the calculation module
#   'buck4t' -- the display tabulator
#   'buck5L' -- the log logger?
#The program uses the subroutine tool:
#   'logvolume' -- a trivial Scribner Log Rule creation algorythm
#The program also relies on the module:
#   'buckPCh' -- the price table updater
#       (though it is not directly integrated)
#----------------------------
#Finally, the table that is created by 'buck2f', and the crux around
#   which this program is built, is a scalable matrix containing variable
#   numbers of different tree bucking combinations (along with
#   their corresponding diameters) specially picked to maximize price
#   while simultaneously minimizing log length (and thus, maximize log
#   truck carrying capacity by minimizing weight).
#These scalable combinations are then tested against each other to find
#   the best pick of the group.

import os
import sys
import Tkinter
import operator
from random import randrange
from buck_2_3 import *
from buckVCF import *
import buckPCh
    
gui_mode = 1

#fig = input('Figure? > ') 

def process_buck(L1,L2,D0,D1,D2,ratio,weight,gui_mode):

    #CALL NEXT MODULE

    #buck0i_1

    if os.path.isfile(sys.path[0]+os.sep+"price_skew.txt"):
        os.remove(sys.path[0]+os.sep+"price_skew.txt")

    target = 60

    i = 200
    while i > 0:
        Length = randrange(L1,L2)                 #setting tree length 

           #Tree descriptor vectors
        log_vector = [0,Length] 
        diameter_vector = [D0,randrange(D1,D2)] 

        # calculations
        (Lf,v1,td1,p1,Lf2,v2,td2,p2) = buck2(Length,log_vector,diameter_vector)
        set_price_skew(target,ratio,weight)
        track_data(Lf,p1,v1)
        i = i - 1

#    buck_result_display(gui_mode,Lf,v1,td1,p1,Lf2,v2,td2,p2)

    graph_data(target)

    os.remove(sys.path[0]+os.sep+"data.txt")



def text_mode_buck():
    if not os.path.isfile(sys.path[0]+os.sep+"prices_file.txt"):
        print "text mode"
        buckPCh.prices_reset()
    else:
        buckPCh.prices_reset_ask()

    no=0 
    n=0 
    yes=1 
    y=1 
    run=0 
    L2=0 
    D0=0 
    D1=0 
    D2=0 

    D0 = float(input('Enter Butt Diameter:  '))           #Get Inputs

    L1 = float(input('Enter Minimum Length:  ')) 
    #L1=L1+0.8333 
    D1 = float(input('Enter Minimum Diameter:  '))
    run=input('Account for diameter reduction?:  ') 
    L2 = float(input('Enter Maximum Length:  '))
#    L2=L2+0.8333 
    D2 = float(input('Enter Maximum Diameter:  '))
    
    process_buck(L1,L2,D0,D1,D2,gui_mode=0)



def gui_process_buck():
    L1 = (L1_entry.get())
    L2 = (L2_entry.get())
    D0 = (D0_entry.get())
    D1 = (D1_entry.get())
    D2 = (D2_entry.get())
    ratio = (ratio_entry.get())
    weight = (weight_entry.get())

    # default values
    if L1 == "":
        L1 = 0
    if L2 == "":
        L2 = 0
    if D0 == "":
        D0 = 0
    if D1 == "":
        D1 = 0
    if D2 == "":
        D2 = 0
    if ratio == "":     # these numbers seem to work well for ratio and weight
        ratio = 0.7
    if weight == "":
        weight = 0.15
    
    L1 = float(L1)
    L2 = float(L2)
    D0 = float(D0)
    D1 = float(D1)
    D2 = float(D2)
    ratio = float(ratio)
    weight = float(weight)

    process_buck(L1,L2,D0,D1,D2,ratio,weight,gui_mode) 

def gui_manage_prices():
    os.system(os.sep+"usr"+os.sep+"bin"+os.sep+"python "+sys.path[0]+os.sep+"buckPCh_g.py &")

def gui_your_logs():
    os.system(os.sep+"usr"+os.sep+"bin"+os.sep+"python "+sys.path[0]+os.sep+"logvalcalc.py &")

#=============== CODE BELOW ===============#
if gui_mode == 1 :  #FIXME: set back to 1 after testing
    if not os.path.isfile(sys.path[0]+os.sep+"prices_file.txt"):
        os.system(os.sep+"usr"+os.sep+"bin"+os.sep+"python "+sys.path[0]+os.sep+"buckPCh_g.py")


    root = Tkinter.Tk()
    root.geometry('400x240+350+70')
    root.title('Buck-Length Calculator')

    welcome = Tkinter.Label(text="Welcome to the buck-length calculator!")

    Tkinter.Label(text="Enter Butt Diameter: ").grid(row=1,column=0)
    D0_entry = Tkinter.Entry(background='white')

    Tkinter.Label(text="Enter Minimum Length: ").grid(row=2,column=0)
    L1_entry = Tkinter.Entry(background='white')
    Tkinter.Label(text="Enter Maximum Length: ").grid(row=3,column=0)
    L2_entry = Tkinter.Entry(background='white')
    Tkinter.Label(text="Enter Minimum Diameter: ").grid(row=4,column=0)
    D1_entry = Tkinter.Entry(background='white')
    Tkinter.Label(text="Enter Maximum Diameter: ").grid(row=5,column=0)
    D2_entry = Tkinter.Entry(background='white')
    Tkinter.Label(text="Enter Converge vs Response Ratio: ").grid(row=6,column=0)
    ratio_entry = Tkinter.Entry(background='white')
    Tkinter.Label(text="Enter Response Weight: ").grid(row=7,column=0)
    weight_entry = Tkinter.Entry(background='white')

    calcbutton = Tkinter.Button(text="Calculate", command=gui_process_buck, activebackground='orange')

    welcome.grid(row=0, column=0, columnspan=3, pady=5)
    D0_entry.grid(row=1,column=1)
    L1_entry.grid(row=2,column=1)
    L2_entry.grid(row=3,column=1)
    D1_entry.grid(row=4,column=1)
    D2_entry.grid(row=5,column=1)
    ratio_entry.grid(row=6,column=1)
    weight_entry.grid(row=7,column=1)
    calcbutton.grid(row=8,column=1,pady=10,rowspan=2)

#   D0_entry.insert(0, '0')
#   L1_entry.insert(0, '0')
#   D1_entry.insert(0, '0')
#   L2_entry.insert(0, '0')
#   D2_entry.insert(0, '0')
#   L3_entry.insert(0, '0')
#   D3_entry.insert(0, '0')

    root.mainloop()

else:
   text_mode_buck()
