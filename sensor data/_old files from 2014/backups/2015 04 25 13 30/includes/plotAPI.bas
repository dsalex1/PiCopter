type plot
	public:
		dim as single range
		dim as single offset
		dim as string lable
		dim as string unit
		declare constructor (range as single,offset as single,lable as string,unit as string)
		declare sub setvalues(value1 as single, value2 as single, value3 as single)
		dim as integer id
	private:
		dim as single lastvalue1,lastvalue2,lastvalue3
		dim as single value1,value2,value3
		dim as integer currentframe
		declare sub redraw
		declare sub drawLegend
		
end type

declare sub redrawplot 'redraws the function plot
declare sub drawLegend 'draws the canvas/lines/etc.
declare sub drawled(x as integer, y as integer, col as ubyte) 'draws an LED at (x|y) in the color col
declare sub addPlot(byref plot_add as plot)
declare sub startplot(hig as integer,wid as integer)



constructor plot (range as single,offset as single,lable as string,unit as string) 
	this.lable=lable
	this.unit=unit
	this.redraw
	currentframe=-1
end constructor

sub plot.setvalues(value1 as single, value2 as single, value3 as single)
	lastvalue1=value1
	lastvalue2=value2
	lastvalue3=value3
	this.value1=value1
	this.value2=value2
	this.value3=value3
end sub

dim shared as plot ptr plots(9)={0,0,0,0,0,0,0,0,0,0}

dim shared as integer currentFrame =0 ' current "frame" - 999 because the canvas will only be drawed when the last frame is achived
dim shared as integer numberOfPlots=0

sub addplot(byref plot_add as plot)
	for i as integer  = 0 to 9 
		if not plots(i)= 0 then plots(i)=@plot_add: plot_add.id=i
	next i
end sub

dim shared as integer plotHeight=0,plotWidth=0

sub startplot(hig as integer,wid as integer)
	plotHeight=hig-2
	plotWidth=wid-2
	for i as integer = 0 to 9
		if not plots(i)=0 then numberOfPlots+=1
	next i
end sub

'lables(1)="accelerometer raw"	:units(1)="g"
'lables(2)="gyroscope raw"		:units(2)=chr(248)+"/s" ' chr(248) = °
'lables(3)="magnetometer raw "	:units(3)="gauss"
'lables(4)="pressure raw"		:units(4)="mbar"
'lables(1)="fused angles"		:units(1)=chr(248)
'lables(2)="altitude"			:units(2)="m"



sub plot.redraw
	'in case we are at the end of the plot area CLear the Screen and redraw canvas/lables/...
	if currentframe = plotWidth-1 or currentframe =-1 then 
		currentframe=0
		line (0,0)-(plotwidth-1,plotHeight/numberofplots*id-1),&h000000
		drawLegend
	end if
	
	line(currentFrame,  (lastvalue1-offset)/range*plotHeight/numberofplots*0.9+plotHeight/2/numberofplots+id*plotHeight/numberofplots)-_
		(currentFrame+1,(value1-    offset)/range*plotHeight/numberofplots*0.9+plotHeight/2/numberofplots+id*plotHeight/numberofplots),&hff0000
	line(currentFrame,  (lastvalue2-offset)/range*plotHeight/numberofplots*0.9+plotHeight/2/numberofplots+id*plotHeight/numberofplots)-_
		(currentFrame+1,(value2-    offset)/range*plotHeight/numberofplots*0.9+plotHeight/2/numberofplots+id*plotHeight/numberofplots),&h00ff00
	line(currentFrame,  (lastvalue3-offset)/range*plotHeight/numberofplots*0.9+plotHeight/2/numberofplots+id*plotHeight/numberofplots)-_
		(currentFrame+1,(value3-    offset)/range*plotHeight/numberofplots*0.9+plotHeight/2/numberofplots+id*plotHeight/numberofplots),&h0000FF

	'print out the absolut values 
	line (0,plotHeight/numberofplots*id+2)-(350,plotHeight/numberofplots*id-12),0,BF
	draw string (5  ,plotHeight/numberofplots*id+3),"X: "+str(this.value1),&hff5555
	draw string (125,plotHeight/numberofplots*id+3),"Y: "+str(this.value2),&h55ff55
	draw string (245,plotHeight/numberofplots*id+3),"Z: "+str(this.value3),&h5555ff
	
	pset (currentframe,0),&h000000 ' blue lines on top of the screen aren't very pretty
	
	currentframe+=1'and finally increment the "frame" counter
end sub


sub plot.drawLegend
	'draw the "title" for every plot: <name> (range: +.. to - ..)
	line (0,800/numberofplots*(id+1))-(1000,800/numberofplots*(id+1))
	dim as string tmp=lable+" (range: "+iif((-range/2)+offset>0,"+","-")+str(abs((-range/2)+offset))+unit+" to "+iif((range/2)+offset>0,"+","-")+str(abs(range/2+offset))+unit+")"
	draw string (500-len(tmp)/2*8,800/numberofplots*id+15),tmp
	
	'draw  a little color legend in the bottom right corner
	line (900,750-5)-(910,760-5),&hff0000,BF
	draw string (920,752-5),"X-axis"
	line (900,770-5)-(910,780-5),&h00ff00,BF
	draw string (920,772-5),"Y-axis"
	line (900,790-5)-(910,800-5),&h0000ff,BF
	draw string (920,792-5),"Z-axis"
	
	'draw the seperators between plots and other things
	line (plotwidth,0)-(plotwidth+2,plotHeight),&hffffff,BF
	line (0,plotHeight)-(plotwidth,plotHeight+2),&hffffff,BF
	'draw the picopter image on the right side
end sub

