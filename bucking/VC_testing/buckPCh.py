#Program-------'buckPCh'
#This is the price updating module of the BUCK program

import os
import sys

no=0 
yes=1 
y = yes 
n = no 


def get_prices():
    if not os.path.isfile(sys.path[0]+os.sep+"prices_file.txt"):
        #graphical mode only
        os.system("python "+sys.path[0]+os.sep+"buckPCh_g.py &") 
        file = open(sys.path[0]+os.sep+"prices_file.txt", mode='r')
    else:
        file = open(sys.path[0]+os.sep+"prices_file.txt", mode='r')
    if not os.path.isfile(sys.path[0]+os.sep+"price_adjuster.txt"):
        price_adjuster_file = open(sys.path[0]+os.sep+"price_adjuster.txt",\
                                    mode='w')
        print >>price_adjuster_file, "1"
        print >>price_adjuster_file, "1"
        print >>price_adjuster_file, "1"
        price_adjuster_file.close()
        price_adjuster_file = open(sys.path[0]+os.sep+"price_adjuster.txt",\
                                    mode='r')
    else:
        price_adjuster_file = open(sys.path[0]+os.sep+"price_adjuster.txt",\
                                    mode='r')

    p16 = float(file.readline())
    p30 = float(file.readline())
    p36 = float(file.readline())
    file.close()

    price_adjuster = float(price_adjuster_file.readline())
    price_adjuster_file.close()

    prices = [p16,p30,p36]
    return (prices,price_adjuster)


def prices_reset():
    file = open(sys.path[0]+os.sep+"prices_file.txt",mode='w')
    print
    p16=input('Enter 16\'to28\' Price:  ') 
    p30=input('Enter 30\'to34\' Price:  ') 
    p36=input('Enter 36\'to40\' Price:  ') 
    file.write(`p16`+"\n")
    file.write(`p30`+"\n")
    file.write(`p36`+"\n")
    file.close()
    print '\n<PRICES LOADED>\n'
    print

def prices_reset_ask():
    PP = 0 
    PP = input('Reset prices? (yes/no):  ') 
    if PP == 1:
        prices_reset()


def debug_buckPCh():
    prices_reset()
    prices = get_prices()
    print prices


