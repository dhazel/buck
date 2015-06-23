#
# based on Li = [0 0 0 0 0]
#
# while Li(1)
#   check iteration number
#       either load start lengh or decrease length by one value
#   calculate length price
#
#   while Li(2)
#       check iteration number
#           either load start lengh or decrease length by one value
#       calculate length price
#
#       while Li(3)
#           check iteration number
#               either load start lengh or decrease length by one value
#           calculate length price
#
#           while Li(4)
#               check iteration number
#                   either load start lengh or decrease length by one value
#               calculate length price
#
#               while Li(5)
#                   check iteration number
#                       either load start lengh or decrease length by one value
#                   calculate length price
#
#               end
#           end
#       end
#   end
# end
#
#

#from numarray import *
from copy import *
import sys
import os
import math
import interpolate
import buck1p
import logvolume_2
import buckPCh

def buck2(L,log,log_dia,gui_mode):
    prices = buckPCh.get_prices()

    Li = [L,0,0,0,0,0]              #length iterators

                                    #Lengths-to-Check Vector 
    LCV = [12,13,22,30,32,38,17,26,34]

    p16 = prices[0]
    p30 = prices[1]
    p36 = prices[2]

    it = [0,0,0,0,0,0]  #iteration tracker (this currently is used
                                    #   to track index of LCV)

    p = [0,0,0,0,0,0]               #price tracker
    p1 = [0,0,0,0,0,0]
    p2 = [0,0,0,0,0,0]
    v = [0,0,0,0,0,0]               #volume tracker
    v1 = [0,0,0,0,0,0]
    v2 = [0,0,0,0,0,0]
    td = [0,0,0,0,0,0]              #top diameter tracker
    td1 = [0,0,0,0,0,0]
    td2 = [0,0,0,0,0,0]
    Lf = [0,0,0,0,0,0]              #lengths tracker
    Lf2 = [0,0,0,0,0,0]             #secondary lengths tracker

    lognum = 5                  #log number control variable

    min_length = 100                #minimum log length variable
    for entry in LCV:               #find minimum length
        if min_length > entry:
	    min_length = entry

    i = 0
    for entry in it:
        it[i] = len(LCV) - 1
        i = i + 1
    
    s=0
    while s >= 0:

        if it[s] == (len(LCV) - 1):     #eg "top" of tree
            while(it[s] != -1):
                if (LCV[it[s]] + 0.8333) <= Li[s]:
                    Li[s] = LCV[it[s]] + 0.8333
                    it[s] = it[s] - 1
                    break
                it[s] = it[s] - 1                     
            if LCV[it[s]] == -1:
                print "\n Too short!\n"
                break
            it[s] = it[s] + 1
        else:                               #middle of tree
            Li[s] = 0
            Li[s+1] = 0
            if(it[s] > -1):
                while (L - sum(Li)) < (LCV[it[s]] + 0.8333):
                    it[s] = it[s] - 1
                    if (it[s] == -1):
                        break

            if (it[s] == -1) & (s == 0):
                break                        # END! QUIT! VAMOS! NOW!
            if (it[s] == -1):
                 #clear all previous log lengths from the top of the tree
                if (s+1) < len(Li):
                    Li[s+1] = 0
                Li[s] = 0   
                p[s] = 0
                v[s] = 0
                td[s] = 0
                it[s] = len(LCV) - 1 
                s = s - 1
                sum_Li = sum(Li)
                continue

            Li[s] = LCV[it[s]] + 0.8333
#        print "s:",s,"Li:",Li,"it:",it
        it[s] = it[s] - 1


#        print 'log loop %i\n' %s
#        print 'Li[s] = %0.4f\n' %Li[s]
#        print 'it[s] = %i\n' %it[s]

                                    #calculate length price
        dia = interpolate.interpolate(sum(Li),log,log_dia)
        dia = int(dia)      #-->FIXME: Look at this later
        td[s] = dia
        v[s] = logvolume_2.logvolume_2(Li[s],dia)
        p[s] = buck1p.buck1p(Li[s],v[s],p16,p30,p36)
        Li[s+1] = L - sum(Li)    #bump remaining length ahead
        sum_p = sum(p)


        if sum_p > sum(p1):
            p2 = copy(p1)
            p1 = copy(p)
            v2 = copy(v1)
            v1 = copy(v)
            td2 = copy(td1)
            td1 = copy(td)
            Lf2 = copy(Lf)
            Lf = copy(Li)
        elif sum_p > sum(p2):
            p2 = copy(p)
            v2 = copy(v)
            td2 = copy(td)
            Lf2 = copy(Li)


        if (Li[s+1] >= (min_length + 0.8333)) & (s < (lognum - 1)):
            s = s + 1


    if gui_mode == 1 :
        # make grandios graphical table of data...
        file = open(sys.path[0]+os.sep+"output.txt",mode='w')

        i = 0
        for entry in v1:  # clean up output to be more user-friendly (clarity)
            if entry == 0:
                Lf[i] = 0
            i = i + 1

        i = 0
        for entry in v2:  # clean up output to be more user-friendly (clarity)
            if entry == 0:
                Lf2[i] = 0
            i = i + 1

        print >>file
        print >>file, "first choice..."
        print >>file, "Lengths are: [%i, %i, %i, %i, %i]" %(Lf[0], Lf[1], Lf[2], Lf[3], Lf[4]), "total:", sum(Lf)
        print >>file, "Volumes are:", v1, "total:", sum(v1)
        print >>file, "Top diams are:", td1
        print >>file, "Prices are: [%3.3f, %3.3f, %3.3f, %3.3f, %3.3f]" %(p1[0], p1[1], p1[2], p1[3], p1[4]), "total:", sum(p1)
        print >>file 
        print >>file, "second choice..."
        print >>file, "Lengths are: [%i, %i, %i, %i, %i]" %(Lf2[0], Lf2[1], Lf2[2], Lf2[3], Lf2[4]), "total:", sum(Lf2)
        print >>file, "Volumes are:", v2, "total:", sum(v2)
        print >>file, "Top diams are:", td2
        print >>file, "Prices are: [%3.3f, %3.3f, %3.3f, %3.3f, %3.3f]" %(p2[0], p2[1], p2[2], p2[3], p2[4]), "total:", sum(p2)
        print >>file 
#        print >>file, "catch_loop:", catch_loop 
#        print >>file 

        file.close()
        os.system("zenity --title=\"Best Buck Lengths\" --info --no-wrap --text=\"`cat "+sys.path[0]+os.sep+"output.txt`\" &")


    else:
        print
        print "first choice..."
        print "Lengths are: [%i, %i, %i, %i, %i]" %(Lf[0], Lf[1], Lf[2], Lf[3], Lf[4]), "total:", sum(Lf)
        print "Volumes are:", v1, "total:", sum(v1)
        print "Top diams are:", td1
        print "Prices are: [%3.3f, %3.3f, %3.3f, %3.3f, %3.3f]" %(p1[0], p1[1], p1[2], p1[3], p1[4]), "total:", sum(p1)
        print
        print "second choice..."
        print "Lengths are: [%i, %i, %i, %i, %i]" %(Lf2[0], Lf2[1], Lf2[2], Lf2[3], Lf2[4]), "total:", sum(Lf2)
        print "Volumes are:", v2, "total:", sum(v2)
        print "Top diams are:", td2
        print "Prices are: [%3.3f, %3.3f, %3.3f, %3.3f, %3.3f]" %(p2[0], p2[1], p2[2], p2[3], p2[4]), "total:", sum(p2)
        print
