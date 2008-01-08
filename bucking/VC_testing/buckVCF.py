
# The Buck volume constraint framework routines
################################################################################

from tcl_tools import *
import sys
import os

# the volume constraint forumula
def set_price_adjuster():
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

    price_adjuster = float(price_adjuster_file.readline())
    adjuster_modifier = float(price_adjuster_file.readline())
    runup_mode = float(price_adjuster_file.readline())
    price_adjuster_file.close

    (perc_total,perc_group,perc_indiv) = compute_percentages()

    # -- calculate price adjuster here -- #
    if (perc_indiv[len(perc_indiv) - 1] != 80):
        adjuster_modifier = ((((80 - perc_indiv[len(perc_indiv) - 1])*1)/100))*1
        if adjuster_modifier > 0:
            print
            print "adjuster_modifier:",adjuster_modifier
            print "price_adjuster:",price_adjuster
    elif (perc_indiv[len(perc_indiv) - 1] == 80):
        adjuster_modifier = 0

    price_adjuster = price_adjuster + adjuster_modifier

        # NOTES:    - we want to always fall back toward price_adjuster = 1
        #           - taller trees can converge very well
        #               - shorter trees (and fewer shippable lengths) offer
        #                   fewer convergence options and can converge poorly
        #           - as a rule of thumb, if the price adjuster is >=2 the 
        #               simple equation is not going to converge
    # ----------------------------------- #

    price_adjuster_file = open(sys.path[0]+os.sep+"price_adjuster.txt",\
                                mode='w')
    print >>price_adjuster_file, price_adjuster
    print >>price_adjuster_file, adjuster_modifier
    print >>price_adjuster_file, runup_mode
    price_adjuster_file.close()

    return


# the percentage calculator
def compute_percentages():
    if not os.path.isfile(sys.path[0]+os.sep+"data.txt"):
        data_file = open(sys.path[0]+os.sep+"data.txt",mode='w')
        data_file.write("volume_in_range = []\ntotal_volume = []")
        data_file.close
        data_file = open(sys.path[0]+os.sep+"data.txt",mode='r')
    else:
        data_file = open(sys.path[0]+os.sep+"data.txt",mode='r')

    exec data_file
    data_file.close

    perc_total = [0.0]
    perc_group = [0.0]
    perc_indiv = [0.0]

    i = 0
    group_indicator = 0
    total_volume_sum = 0
    volume_in_range_sum = 0
    group_total_volume_sum = 0
    group_volume_in_range_sum = 0
    for element in total_volume:
        total_volume_sum = total_volume_sum + total_volume[i]
        volume_in_range_sum = volume_in_range_sum + volume_in_range[i]
        group_total_volume_sum = group_total_volume_sum + total_volume[i]
        group_volume_in_range_sum = group_volume_in_range_sum+volume_in_range[i]
        perc_total.append((volume_in_range_sum * 100 / total_volume_sum))
        perc_indiv.append((volume_in_range[i] * 100 / total_volume[i]))

        if group_indicator == 9:
            group_indicator = 0
            perc_group.append((group_volume_in_range_sum * 100 / group_total_volume_sum))
            group_total_volume_sum = 0
            group_volume_in_range_sum = 0

        i = i + 1
        group_indicator = group_indicator + 1

    return (perc_total,perc_group,perc_indiv)


# the data tracker
def track_data(Lf,p1,v1):
    # track only for valid shippable logs
    # track total volume-in-range, total volume
    # track groups of ten trees -- total volume-in-range, total volume
    # track individual trees -- volume-in-range, volume

    if not os.path.isfile(sys.path[0]+os.sep+"data.txt"):
        data_file = open(sys.path[0]+os.sep+"data.txt",mode='w')
        data_file.write("volume_in_range = []\ntotal_volume = []")
        data_file.close
        data_file = open(sys.path[0]+os.sep+"data.txt",mode='r')
    else:
        data_file = open(sys.path[0]+os.sep+"data.txt",mode='r')

    exec data_file
    data_file.close

    valid_logs_in_tree = 0
    for entry in p1:
        if entry == 0:
            break
        valid_logs_in_tree = valid_logs_in_tree + 1

    i = 0
    vsum = 0
    vrangesum = 0
    while valid_logs_in_tree > 0:
        vsum = vsum + v1[i]
        if Lf[i] >= 32:
            vrangesum = vrangesum + v1[i]
        i = i + 1
        valid_logs_in_tree = valid_logs_in_tree - 1

    total_volume.append(vsum)
    volume_in_range.append(vrangesum)

    data_file = open(sys.path[0]+os.sep+"data.txt",mode='w')
    print >>data_file, "volume_in_range = [\\"
    for element in volume_in_range:
        print >>data_file, element,",\\"
    print >>data_file, "]"
    print >>data_file, "total_volume = [\\"
    for element in total_volume:
        print >>data_file, element,",\\"
    print >>data_file, "]"
    data_file.close


# the data grapher
def graph_data():
    # get y-axis data
    (perc_total,perc_group,perc_indiv) = compute_percentages()

    # generate x-axis data
    i = 0
    x_axis_indiv = []
    for entry in perc_total:
        x_axis_indiv.append(i)
        i = i + 1

    i = 0
    x_axis_group = []
    for entry in perc_group:
        x_axis_group.append(i * 10)
        i = i + 1

    # generate x-y target data
    x_target = [0,(len(perc_total))]
    y_target = [80,80]

    # graph the data
    tcl_graph("Volume Constraint Characteristics","Trees","Percent Volume",\
                "target",x_target,y_target,"blue",\
                "total",x_axis_indiv,perc_total,"red",\
                "group",x_axis_group,perc_group,"orange",\
                "individual",x_axis_indiv,perc_indiv,"green")


