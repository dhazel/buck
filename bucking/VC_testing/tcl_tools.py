#!/usr/bin/python

import os

# tcl graph tool
def tcl_graph(title,xtitle,ytitle,line1_name,xdata1,ydata1,color1="blue",\
                line2_name=0,xdata2=[],ydata2=[],color2="blue",\
                line3_name=0,xdata3=[],ydata3=[],color3="blue",\
                line4_name=0,xdata4=[],ydata4=[],color4="blue"):

    # Open tclsh and pipe commands to it via the "graph" file descriptor
    (graph) = os.popen("tclsh",'w')

    # Feed tcl commands to tclsh that will create the initial graph 
    print >>graph, "package require Tk"
    print >>graph, "package require BLT"
    print >>graph, "::blt::graph .g"
    print >>graph, "pack .g"
    print >>graph, ".g axis configure x -title \"",xtitle,"\""
    print >>graph, ".g axis configure y -title \"",ytitle,"\""
    print >>graph, ".g configure -title \"",title,"\""
    print >>graph, ".g grid on"

    # Draw the mandatory data line
    print >>graph, ".g element create ",line1_name," -color ",color1," \\"
    print >>graph, "-xdata { \\"
    for element in xdata1:
        print >>graph, element," \\"
    print >>graph, "} \\"
    print >>graph, "-ydata { \\"
    for element in ydata1:
        print >>graph, element," \\"
    print >>graph, "}"

    # Draw the optional data lines
    #   Line2 ----
    if (line2_name != 0):
        print >>graph, ".g element create ",line2_name," -color ",color2," \\"
        print >>graph, "-xdata { \\"
        for element in xdata2:
            print >>graph, element," \\"
        print >>graph, "} \\"
        print >>graph, "-ydata { \\"
        for element in ydata2:
            print >>graph, element," \\"
        print >>graph, "}"

    #   Line3 ----
    if (line3_name != 0):
        print >>graph, ".g element create ",line3_name," -color ",color3," \\"
        print >>graph, "-xdata { \\"
        for element in xdata3:
            print >>graph, element," \\"
        print >>graph, "} \\"
        print >>graph, "-ydata { \\"
        for element in ydata3:
            print >>graph, element," \\"
        print >>graph, "}"

    #   Line4 ----
    if (line4_name != 0):
        print >>graph, ".g element create ",line4_name," -color ",color4," \\"
        print >>graph, "-xdata { \\"
        for element in xdata4:
            print >>graph, element," \\"
        print >>graph, "} \\"
        print >>graph, "-ydata { \\"
        for element in ydata4:
            print >>graph, element," \\"
        print >>graph, "}"

    (graph) = os.popen("tclsh",'w')
    graph.close()

# --- CODE BELOW --- #

#tcl_graph("My Plot","x axis","y axis","lineA",[0,1,2,2.5],[2,1,0,1.5],"green",\
#            "lineB",[0,1,2,3],[1,1,1,1],"blue")



