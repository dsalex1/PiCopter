#inclib "I2C"

declare sub write_I2C cdecl alias "write_I2C" (address as unsigned byte, reg as unsigned byte, value as unsigned byte )
declare function read_I2C cdecl alias "read_I2C" (address as unsigned byte, reg as unsigned byte) as unsigned byte

' &h6d --> gyrometer L3GD60H
' &h1d --> accelerometer/magnetometer LSM303D
' &h5d --> Barometer
'
'

screenres 1500,800,32
declare sub initsensors
declare sub getsensorvalues
declare sub nextplot
declare sub drawLegend
declare sub drawled(x as integer, y as integer, col as integer)

dim shared as any ptr picopter
picopter=imagecreate(375,529)
bload "picopter.bmp",picopter
dim shared as integer rawpressure=0

dim shared as short rawGyroX=0
dim shared as short rawGyroZ=0
dim shared as short rawGyroY=0
dim shared as byte  rawGyroTemp=0

dim shared as short rawAccX=0
dim shared as short rawAccY=0
dim shared as short rawAccZ=0

dim shared as single AccXangle=0
dim shared as single AccYangle=0

dim shared as short rawMagX=0
dim shared as short rawMagZ=0
dim shared as short rawMagY=0
dim shared as short rawAccMagTemp=0

dim shared as single outputX=0,outputY=0,outputZ=0

dim shared as integer x =999

dim shared as single plotvalues(1 to 3, 1 to 6)
dim shared as single lastplotvalues(1 to 3, 1 to 6)
dim shared as single ranges(1 to 6)
dim shared as string lables(1 to 6)

lables(1)="accelerometer raw"
lables(2)="accelerometer angles"
lables(3)="gyroscope raw"
lables(4)="magnetometer raw "
lables(6)="pressure raw"
lables(5)="fused angles"



initsensors
drawLegend
do
	getsensorvalues
	
	accxangle=atn(rawAccY/sqr(rawAccX^2+rawAccZ^2))/3.1415*180
	accYangle=atn(-rawAccx/rawAccZ)/3.1415*180
	outputX=0.98*(outputX-rawGyroX/2^16*80)+0.02*accxangle
	outputY=0.98*(outputY+rawGyroY/2^16*80)+0.02*accYangle
	
	if (rawMagZ-300)/2000/0.6>1 then
		outputZ=asin(1)/3.1415*180
	elseif (rawMagZ-300)/2000/0.6<-1 then 
		outputZ=asin(-1)/3.1415*180
	else
		outputZ=asin((rawMagZ-300)/2000/0.6)/3.1415*180
	end if
	
	ranges(1)=40000
	plotvalues(1, 1)=rawAccX
	plotvalues(2, 1)=rawAccY
	plotvalues(3, 1)=rawAccZ
	
	ranges(2)=180
	plotvalues(1, 2)=accxangle	
	plotvalues(2, 2)=accYangle
	plotvalues(3, 2)=0
	
	ranges(3)=20000
	plotvalues(1, 3)=rawGyroX
	plotvalues(2, 3)=rawGyroY
	plotvalues(3, 3)=rawGyroZ
	
	ranges(4)=10000
	plotvalues(1, 4)=rawMagX
	plotvalues(2, 4)=rawMagY
	plotvalues(3, 4)=rawMagZ
	
	ranges(5)=180
	plotvalues(1, 5)=outputX
	plotvalues(2, 5)=outputY
	plotvalues(3, 5)=outputZ
	
	ranges(6)=4000
	plotvalues(1, 6)=0
	plotvalues(2, 6)=plotvalues(2, 6)*0.9+(rawpressure-3996400)*0.1
	plotvalues(3, 6)=rawpressure-3996400
	
	nextplot
loop while inkey=""
end



'********************************************************************************************************************
'subs:
sub nextplot
	for i as integer = 1 to ubound(plotvalues,2)
		line(x,lastplotvalues(1, i)/ranges(i)*800/ubound(plotvalues,2)*0.9+400/ubound(plotvalues,2)+(i-1)*800/ubound(plotvalues,2))-(x+1,plotvalues(1, i)/ranges(i)*800/ubound(plotvalues,2)*0.9+400/ubound(plotvalues,2)+(i-1)*800/ubound(plotvalues,2)),&hff0000
		line(x,lastplotvalues(2, i)/ranges(i)*800/ubound(plotvalues,2)*0.9+400/ubound(plotvalues,2)+(i-1)*800/ubound(plotvalues,2))-(x+1,plotvalues(2, i)/ranges(i)*800/ubound(plotvalues,2)*0.9+400/ubound(plotvalues,2)+(i-1)*800/ubound(plotvalues,2)),&h00ff00
		line(x,lastplotvalues(3, i)/ranges(i)*800/ubound(plotvalues,2)*0.9+400/ubound(plotvalues,2)+(i-1)*800/ubound(plotvalues,2))-(x+1,plotvalues(3, i)/ranges(i)*800/ubound(plotvalues,2)*0.9+400/ubound(plotvalues,2)+(i-1)*800/ubound(plotvalues,2)),&h0000FF
	next i
	if x = 999 then 
		x=0
		cls
		drawLegend
	end if
	for i as integer= 1 to 3
		for j as integer = 1 to ubound(plotvalues,2)
			lastplotvalues(i, j)=plotvalues(i, j)
		next j
	next i
	for i as integer = 1 to ubound(plotvalues,2)
		line (0,800/ubound(plotvalues,2)*(i-1)+2)-(350,800/ubound(plotvalues,2)*(i-1)+12),0,BF
		draw string (5,800/ubound(plotvalues,2)*(i-1)+3),"X: "+str(plotvalues(1, i)),&hff5555
		draw string (125,800/ubound(plotvalues,2)*(i-1)+3),"Y: "+str(plotvalues(2, i)),&h55ff55
		draw string (245,800/ubound(plotvalues,2)*(i-1)+3),"Z: "+str(plotvalues(3, i)),&h5555ff
	next i
	pset (x,0),&h000000
	x+=1
end sub

sub drawLegend
	for i as integer = 1 to ubound(plotvalues,2)
		line (0,800/ubound(plotvalues,2)*i)-(1000,800/ubound(plotvalues,2)*i)
		draw string (500-len(lables(i)+" (range: -"+str(ranges(i)/2)+" to +"+str(ranges(i)/2)+")")/2*8,800/ubound(plotvalues,2)*(i-1)+15),lables(i)+" (range: -"+str(ranges(i)/2)+" to +"+str(ranges(i)/2)+")"
	next i
	line (900,750-5)-(910,760-5),&hff0000,BF
	draw string (920,752-5),"X-axis"
	line (900,770-5)-(910,780-5),&h00ff00,BF
	draw string (920,772-5),"Y-axis"
	line (900,790-5)-(910,800-5),&h0000ff,BF
	draw string (920,792-5),"Z-axis"
	
	line (1000,0)-(1002,800),&hffffff,BF
	
	put(1066,135),picopter,pset
	drawled(1249,170,60)
	drawled(1249,630,120)
	drawled(1099,411,180)
	drawled(1404,411,255)
end sub

sub drawled(x as integer, y as integer, inten as integer)
	circle(x,y),20,&h010100*inten,,,,F
	for i as integer = 1 to 10
		line(x+cos(360/10*i/180*3.1415)*30,y+sin(360/10*i/180*3.1415)*30)-(x+cos(360/10*i/180*3.1415)*50,y+sin(360/10*i/180*3.1415)*50),&h010100*int(inten^3/255^2)
	next i
end sub
sub initsensors
	write_I2C(&h6b,&h20,&h0F)
	write_I2C(&h6b,&h23,&h30)
	write_I2C(&h1d,&h20,&h57)
	write_I2C(&h1d,&h24,&hF0)
	write_I2C(&h1d,&h26,&h00)
	write_I2C(&h5d,&h20,&hc0)
end sub 

sub getsensorvalues
	rawGyroX= read_I2C(&h6b,&h28) or (read_I2C(&h6b,&h29) shl 8)
	if rawGyroX shr 15 = 1 then rawGyroX = -(&hFFFF-rawGyroX+1)
	rawGyroY= read_I2C(&h6b,&h2A)  or (read_I2C(&h6b,&h2B) shl 8)
	if rawGyroY shr 15 = 1 then rawGyroY = -(&hFFFF-rawGyroY+1)
	rawGyroY=rawGyroY-38
	rawGyroZ= read_I2C(&h6b,&h2C) or (read_I2C(&h6b,&h2D) shl 8)
	if rawGyroZ shr 15 = 1 then rawGyroZ = -(&hFFFF-rawGyroZ+1)
		
	rawGyroTemp= read_I2C(&h6b,&h26)
	if rawGyroTemp shr 7 = 1 then rawGyroTemp = -(&hFF-rawGyroTemp+1)
		
	rawAccX= read_I2C(&h1d,&h28) or (read_I2C(&h1d,&h29) shl 8)
	if rawAccX shr 15 = 1 then rawAccX = -(&hFFFF-rawAccX+1)
	rawAccY= read_I2C(&h1d,&h2A)  or (read_I2C(&h1d,&h2B) shl 8)
	if rawAccY shr 15 = 1 then rawAccY = -(&hFFFF-rawAccY+1)
	rawAccZ= read_I2C(&h1d,&h2C)  or (read_I2C(&h1d,&h2D) shl 8)
	if rawAccZ shr 15 = 1 then rawAccZ = -(&hFFFF-rawAccZ+1)
		
	rawMagX= read_I2C(&h1d,&h08) or (read_I2C(&h1d,&h09) shl 8)	
	if rawMagX shr 15 = 1 then rawMagX = -(&hFFFF-rawMagX+1)
	rawMagY= read_I2C(&h1d,&h0C)  or (read_I2C(&h1d,&h0D) shl 8)
	if rawMagY shr 15 = 1 then rawMagY = -(&hFFFF-rawMagY+1)
	rawMagY=rawMagY-38
	rawMagZ= read_I2C(&h1d,&h0A) or (read_I2C(&h1d,&h0B) shl 8)
	if rawMagZ shr 15 = 1 then rawMagZ = -(&hFFFF-rawMagZ+1)
		
	rawAccMagTemp= read_I2C(&h1d,&h05)  or (read_I2C(&h1d,&h06) shl 8)
	if rawAccMagTemp shr 11 = 1 then rawAccMagTemp = -(&h0FFF-rawAccMagTemp+1)
	
	rawpressure= read_I2C(&h5d,&h28)  or (read_I2C(&h5d,&h29) shl 8) or (read_I2C(&h5d,&h2a) shl 16)
end sub
