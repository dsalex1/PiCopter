'*************USEAGE***************+++
'
'only works in a graphic window
'
'first create some instances of the type plot
'with the preferented propertys plot(range,offset,lable,unit)
'range  - total range of the graph
'offset - offset from the middle of range 
'         (eg. range=100 offset=10 == abs.range -40 to +60)
'lable  - "name" of the graph, will be shown
'unit   - units of the range values, will be shown
'
'eg. dim as plot myPlot=plot(100,0,"myGraph","cm")
'would create a plot in range -50cm to +50cm named myGraph
'
'if all plots a created start the plot with the preferented size:
'startplot(width,height)
'now run in a loop:
'   for each plot created do (eg. myplot)
'   'myPlot.setvalues(value1,value2,value3)'
'   and 'redrawplot' to refresh the display
'
'in the end is a example of a plot of multiple values uncomment 
'and compile this file like a normal program to test it
declare sub linemasked (x1 as integer,y1 as integer,x2 as integer,y2 as integer,mask as integer)

type plot
	public:
        dim as single range
		dim as single offset
		dim as string lable
		dim as string unit
		declare constructor (range as single,offset as single,lable as string,unit as string)
		declare sub setvalues(value1 as single, value2 as single, value3 as single)
		declare sub redraw
		declare sub setoffset(offset as single)
        dim as integer id
        dim as single value1,value2,value3
	private:
		dim as single lastvalue1,lastvalue2,lastvalue3
		dim as integer currentframe
		declare sub drawLegend
		
end type

declare sub redrawplot 'redraws the function plot
declare sub drawLegend 'draws the canvas/lines/etc.
declare sub drawled(x as integer, y as integer, col as ubyte) 'draws an LED at (x|y) in the color col
declare sub addPlot(byref plot_add as plot)
declare sub startplot(hig as integer,wid as integer)



constructor plot (range as single,offset as single,lable as string,unit as string) 
	this.offset=offset
    this.range=range
	this.lable=lable
	this.unit=unit
	this.redraw
	currentframe=-1
    addplot(this)
end constructor

sub plot.setvalues(value1 as single, value2 as single =0, value3 as single =0)
	lastvalue1=this.value1
	lastvalue2=this.value2
	lastvalue3=this.value3
	this.value1=value1
	this.value2=value2
	this.value3=value3
end sub

sub plot.setoffset(offset as single)
	if abs(this.offset-offset)>0.0001 then
		this.offset=offset
		this.drawlegend
	end if
end sub


dim shared as plot ptr plots(9)={0,0,0,0,0,0,0,0,0,0}

dim shared as integer currentFrame =0 ' current "frame" - 999 because the canvas will only be drawed when the last frame is achived
dim shared as integer numberOfPlots=0

sub addplot(byref plot_add as plot)
	for i as integer  = 0 to 9 
		if plots(i)= 0 then 
            plots(i)=@plot_add
            (*plots(i)).id = i
            exit for
        end if
	next i
end sub

dim shared as integer plotHeight=0,plotWidth=0

sub startplot(wid as integer,hig as integer)
	plotHeight=hig-2
	plotWidth=wid-2
	for i as integer = 0 to 9
		if not plots(i)=0 then numberOfPlots+=1
	next i
end sub

sub redrawplot
    for i as integer = 0 to 9
		if not plots(i)=0 then (*plots(i)).redraw
	next i
end sub


sub plot.redraw
    'in case we are at the end of the plot area Clear the Screen and redraw canvas/lables/...
	if currentframe = plotWidth-1 or currentframe =-1 then 
		currentframe=0
		drawLegend
	end if
	line(currentFrame,  (-lastvalue1+offset)/range*plotHeight/numberofplots*0.9+(id+0.5)*plotHeight/numberofplots)-_
		(currentFrame+1,(-value1+    offset)/range*plotHeight/numberofplots*0.9+(id+0.5)*plotHeight/numberofplots),&hff0000
	line(currentFrame,  (-lastvalue2+offset)/range*plotHeight/numberofplots*0.9+(id+0.5)*plotHeight/numberofplots)-_
		(currentFrame+1,(-value2+    offset)/range*plotHeight/numberofplots*0.9+(id+0.5)*plotHeight/numberofplots),&h00ff00
	line(currentFrame,  (-lastvalue3+offset)/range*plotHeight/numberofplots*0.9+(id+0.5)*plotHeight/numberofplots)-_
		(currentFrame+1,(-value3+    offset)/range*plotHeight/numberofplots*0.9+(id+0.5)*plotHeight/numberofplots),&h0000FF

	'print out the absolut values 
	line (0,plotHeight/numberofplots*id+1)-(plotwidth-1,plotHeight/numberofplots*id+12),&h000000,BF
	draw string (5  ,plotHeight/numberofplots*id+3),"X: "+str(this.value1),&hff5555
	draw string (125,plotHeight/numberofplots*id+3),"Y: "+str(this.value2),&h55ff55
	draw string (245,plotHeight/numberofplots*id+3),"Z: "+str(this.value3),&h5555ff
	
	pset (currentframe,0),&h000000 ' blue lines on top of the screen aren't very pretty
	
	currentframe+=1'and finally increment the "frame" counter
end sub


sub plot.drawLegend
    'delete all stuff
    line (0,plotHeight/numberofplots*id+12)-(plotwidth,plotHeight/numberofplots*(id+1)-1),&h000000,BF
	
	'draw  seperator and null-line
	line (0,plotHeight/numberofplots*(id+1))-(plotwidth,plotHeight/numberofplots*(id+1))
	linemasked 0, plotHeight/numberofplots*(id+0.5 ), plotwidth, plotHeight/numberofplots*(id+0.5 ), &b1100110011001100
	linemasked 0, plotHeight/numberofplots*(id+0.25), plotwidth, plotHeight/numberofplots*(id+0.25), &b1000000010000000
	linemasked 0, plotHeight/numberofplots*(id+0.75), plotwidth, plotHeight/numberofplots*(id+0.75), &b1000000010000000
	
    'draw the "title" for every plot: <name> (range: +.. to - ..)
    dim as string tmp=lable+" (range: "+iif((-range/2)+offset>0,"+","-")+str(abs((-range/2)+offset))+unit+" to "+iif((range/2)+offset>0,"+","-")+str(abs(range/2+offset))+unit+")"
	draw string (plotwidth/2-len(tmp)/2*8,plotHeight/numberofplots*id+15),tmp
	
	'draw the seperators between plots and other things
	line (plotwidth,0)-(plotwidth+2,plotHeight),&hffffff,BF
	line (0,plotHeight)-(plotwidth,plotHeight+2),&hffffff,BF
end sub

sub linemasked (x1 as integer,y1 as integer,x2 as integer,y2 as integer,mask as integer)
	for i as integer = x1 to x2
		if ((mask shr (i mod 16)) and 1) then pset (i,y1)
	next i
end sub
'
'screenres 600,600,32
'dim as plot test1 = plot(1000,500,"test1","px")
'dim as plot test2 = plot(1000,500,"test2","px")
'dim as plot test3 = plot(4000,100,"test3","°")
'dim as plot test4 = plot(4000,100,"tefze","l")
'
'startplot(600,600)
'
'do
'	for i as integer=-500 to 500
'        test1.setvalues((i/25)^2,0,0)
'        test2.setvalues(i,-i,0)
'        test3.setvalues(i,-(i/25)^2,0)
'        test4.setvalues(-670,(i/25),4)
'		redrawplot
'        sleep 10
'	next i
'loop while inkey=""
'sleep
