#This function is a simple log price checker

import buckPCh
import sys
import os
#if not os.path.isfile(sys.path[0]+os.sep+"prices_file.txt"):
#    buckPCh.prices_reset()


def buck1p(Length,Volume,p16,p30,p36):
    Length = Length - (0.8333) 

    if Length >= 16:
        if Length <= 28:
            price = (Volume/1000) * p16 
        elif Length <= 34:
            price = (Volume/1000) * p30 
        elif Length <= 40:
            price = (Volume/1000) * p36 
        else:
            print 'Error: Log is wrong length!'
            price = 0
    else:
        print 'Error: Log is wrong length!'
        price = 0 

    price = (Volume/1000) * 500

    return price

def debug_buck1p():
    buckPCh.prices_reset_ask()
    prices = buckPCh.get_prices()
    price = buck1p(float(input("Length: ")),float(input("Volume: ")),prices[0],prices[1],prices[2])
    print "price is:", price, "dollars"


