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
import buck_1_4
import buckPCh
import logvolume_2
import buck1p

    
no=0 
yes=1 
run=0 
L2=0 
L3=0 
D0=0 
D1=0 
D2=0 
D3=0 


def gui_process_logs():

    lengths = [0,0,0,0,0]
    diameters = [0,0,0,0,0]
    volumes = [0,0,0,0,0]
    values = [0,0,0,0,0]
    
    prices = buckPCh.get_prices()

    L1 = (L1_entry.get())
    L2 = (L2_entry.get())
    L3 = (L3_entry.get())
    L4 = (L4_entry.get())
    L5 = (L5_entry.get())
    D1 = (D1_entry.get())
    D2 = (D2_entry.get())
    D3 = (D3_entry.get())
    D4 = (D4_entry.get())
    D5 = (D5_entry.get())

    if L1 == "":
        lengths[0] = 0
    else:
        lengths[0] = float(L1) + 0.8333  # putting it here fixes 0-length output
    if L2 == "":
        lengths[1] = 0
    else:
        lengths[1] = float(L2) + 0.8333
    if L3 == "":
        lengths[2] = 0
    else:
        lengths[2] = float(L3) + 0.8333
    if L4 == "":
        lengths[3] = 0
    else:
        lengths[3] = float(L4) + 0.8333
    if L5 == "":
        lengths[4] = 0
    else:
        lengths[4] = float(L5) + 0.8333
    if D1 == "":
        D1 = 0
    if D2 == "":
        D2 = 0
    if D3 == "":
        D3 = 0
    if D4 == "":
        D4 = 0
    if D5 == "":
        D5 = 0
    
    diameters[0] = int(D1)
    diameters[1] = int(D2)
    diameters[2] = int(D3)
    diameters[3] = int(D4)
    diameters[4] = int(D5)

    i = 0
    for entry in lengths:
        volumes[i] = logvolume_2.logvolume_2(lengths[i],diameters[i])
        values[i] = buck1p.buck1p(lengths[i],volumes[i],prices[0],prices[1],prices[2])
        i = i + 1


    # make grandios graphical table of data...
    file = open(sys.path[0]+os.sep+"val_output.txt",mode='w')

    print >>file
    print >>file, "Your choices..."
    print >>file, "Lengths are: [%i, %i, %i, %i, %i]" %(lengths[0], lengths[1], lengths[2], lengths[3], lengths[4]), "total:", sum(lengths)
    print >>file, "Volumes are:", volumes, "total:", sum(volumes)
    print >>file, "Top diams are:", diameters
    print >>file, "Prices are: [%3.3f, %3.3f, %3.3f, %3.3f, %3.3f]" %(values[0], values[1], values[2], values[3], values[4]), "total:", sum(values)
    print >>file 

    file.close()
    os.system("gedit "+sys.path[0]+os.sep+"val_output.txt &")


def gui_manage_prices():
    os.system(os.sep+"usr"+os.sep+"bin"+os.sep+"python "+sys.path[0]+os.sep+"buckPCh_g.py &")


#=============== CODE BELOW ===============#
if not os.path.isfile(sys.path[0]+os.sep+"prices_file.txt"):
    os.system(os.sep+"usr"+os.sep+"bin"+os.sep+"python "+sys.path[0]+os.sep+"buckPCh_g.py")


root = Tkinter.Tk()
root.geometry('300x300+350+370')
root.title('Log Value Calculator')

welcome = Tkinter.Label(text="Welcome to the log value calculator!")

Tkinter.Label(text="Enter Log Length: ").grid(row=1,column=0)
L1_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter End Diameter: ").grid(row=2,column=0)
D1_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter Log Length: ").grid(row=3,column=0)
L2_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter End Diameter: ").grid(row=4,column=0)
D2_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter Log Length: ").grid(row=5,column=0)
L3_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter End Diameter: ").grid(row=6,column=0)
D3_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter Log Length: ").grid(row=7,column=0)
L4_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter End Diameter: ").grid(row=8,column=0)
D4_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter Log Length: ").grid(row=9,column=0)
L5_entry = Tkinter.Entry(background='white')
Tkinter.Label(text="Enter End Diameter: ").grid(row=10,column=0)
D5_entry = Tkinter.Entry(background='white')

calcbutton = Tkinter.Button(text="Calculate Values", command=gui_process_logs, activebackground='green')
Tkinter.Button(text="Close", command=root.destroy).grid(row=11,column=0,pady=10)

welcome.grid(row=0, column=0, columnspan=3, pady=5)
L1_entry.grid(row=1,column=1)
D1_entry.grid(row=2,column=1)
L2_entry.grid(row=3,column=1)
D2_entry.grid(row=4,column=1)
L3_entry.grid(row=5,column=1)
D3_entry.grid(row=6,column=1)
L4_entry.grid(row=7,column=1)
D4_entry.grid(row=8,column=1)
L5_entry.grid(row=9,column=1)
D5_entry.grid(row=10,column=1)
calcbutton.grid(row=11,column=1,pady=10)

#   D0_entry.insert(0, '0')
#   L1_entry.insert(0, '0')
#   D1_entry.insert(0, '0')
#   L2_entry.insert(0, '0')
#   D2_entry.insert(0, '0')
#   L3_entry.insert(0, '0')
#   D3_entry.insert(0, '0')

root.mainloop()

