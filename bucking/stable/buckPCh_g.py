#Program-------'buckPCh'
#This is the price updating module of the BUCK program

import os
import sys
import time
import Tkinter
import buckPCh

no=0 
yes=1 
y = yes 
n = no 


def prices_write_begin():
    status.delete(0,"end")
    status.insert(0,'    < SAVING... >')

    p16 = float(p16_entry.get())
    p30 = float(p30_entry.get())
    p36 = float(p36_entry.get())
  
    prices_file_write(p16,p30,p36)

def prices_file_write(p16,p30,p36):
    file = open(sys.path[0]+os.sep+"prices_file.txt",mode='w')
    file.write(`p16`+"\n")
    file.write(`p30`+"\n")
    file.write(`p36`+"\n")
    file.close()

    time.sleep(2)
    status.delete(0,"end")
    status.insert(0,'< PRICES SAVED >')
    

#================ CODE BELOW ==================#
root = Tkinter.Tk()
root.geometry('280x145+700+100')
root.title('Price Manager')

Tkinter.Label(text="Price Manager").grid(row=0,column=0,columnspan=2)

status = Tkinter.Entry()

if not os.path.isfile(sys.path[0]+os.sep+"prices_file.txt"):
    prices = [0,0,0]
    status.delete(0,"end")
    status.insert(0,'< PRICES EMPTY >')
else:
    prices = buckPCh.get_prices()
    status.delete(0,"end")
    status.insert(0,'< PRICES PRESENT >')

p16_entry = Tkinter.Entry(background='yellow')
p30_entry = Tkinter.Entry(background='yellow')
p36_entry = Tkinter.Entry(background='yellow')

p16_entry.grid(row=1,column=1)
p30_entry.grid(row=2,column=1)
p36_entry.grid(row=3,column=1)

p16_entry.insert(0,prices[0])
p30_entry.insert(0,prices[1])
p36_entry.insert(0,prices[2])



Tkinter.Label(text="Enter 16\'to28\' price:").grid(row=1,column=0)
Tkinter.Label(text="Enter 30\'to34\' price:").grid(row=2,column=0)
Tkinter.Label(text="Enter 36\'to40\' price:").grid(row=3,column=0)

load_button = Tkinter.Button(text="Save Prices", command=prices_write_begin)

status.grid(row=4,column=0,columnspan=2)
load_button.grid(row=5,column=1)

exit_button = Tkinter.Button(text="Close", command=root.destroy)
exit_button.grid(row=5,column=0)

root.mainloop()



def debug_buckPCh():
    prices = get_prices()
    print prices


