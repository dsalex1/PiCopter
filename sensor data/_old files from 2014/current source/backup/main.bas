'#define Right_LED GPIO_11
'#define Back_LED GPIO_16
'#define Front_LED GPIO_22
'#define Left_LED GPIO_23

#include once "includes/PID_Controller.bas" 'provide PID controller function PID(...)  
#include once "includes/sensorAPI.bas" 'provide sensor communication getorientaiton()... 
#include once "includes/plotAPI.bas"

' sensor addresses:
' &h6d --> gyrometer L3GD60H
' &h1d --> accelerometer/magnetometer LSM303D
' &h5d --> Barometer


screenres 1500,800,32

'loading the picoper image and "store it in "picopter"
dim shared as any ptr picopter
picopter=imagecreate(375,529)
bload "data_files/picopter.bmp",picopter

'variables to store calculated values like orientation/altitude/motorspeeds
dim as orientation curentOrientation
dim as position curentPosition
dim as motorspeeds curentMotorSpeeds

'dim as plot accelerometer_raw=new plot(3,0,"accelerometer raw","g")
'lables(1)="accelerometer raw"	:units(1)="g"
'lables(2)="gyroscope raw"		:units(2)=chr(248)+"/s" ' chr(248) = °
'lables(3)="magnetometer raw "	:units(3)="gauss"
'lables(4)="pressure raw"		:units(4)="mbar"
'lables(1)="fused angles"		:units(1)=chr(248)
'lables(2)="altitude"			:units(2)="m"

'*************************************************************************************************************************

'prepearing: initialize the sensors
initsensors()


'startplot()
'main loop: getting sensor values; calculate orientationa and altitude ; plot sensor values and draw "simulated" picopter 
do

	getSensorValues 'getting all raw values
	
	curentOrientation=getOrientation()
	
	curentPosition=getPosition() 'currently only altitude	

	curentmotorspeeds=PID(,,,curentOrientation.Roll,curentOrientation.Pitch,0,,,)  'let the PID controller calculate the motorspeeds and store them in motorspeeds (range 0 to 100)
	
	locate 1,1
	print curentorientation.roll,curentOrientation.pitch,"      "
	' "simulate" the picopter by drawing leds in the according brightniss
	'drawled(1249,170,curentmotorspeeds.f*2.55)
	'drawled(1249,630,curentmotorspeeds.b*2.55)
	'drawled(1099,411,curentmotorspeeds.r*2.55)
	'drawled(1404,411,curentmotorspeeds.l*2.55)
	
	
	
	
	''plot the values:
	
	'' /--> dont plot unneccesary data 
	''/
	''ranges(1)=3
	'accelerometer_raw.value1=rawAccX/2^15*2
	'accelerometer_raw.value2=rawAccY/2^15*2
	'accelerometer_raw.value3=rawAccZ/2^15*2
	''plotvalues(2, 1)=rawAccY/2^15*2
	''plotvalues(3, 1)=rawAccZ/2^15*2
	
	''ranges(2)=720
	''plotvalues(1, 2)=rawGyroX/2^15*2000
	''plotvalues(2, 2)=rawGyroY/2^15*2000
	''plotvalues(3, 2)=rawGyroZ/2^15*2000
	
	''ranges(3)=4
	''plotvalues(1, 3)=rawMagX/2^12*1.3
	''plotvalues(2, 3)=rawMagY/2^12*1.3
	''plotvalues(3, 3)=rawMagZ/2^12*1.3
	
	''ranges(4)=1
	''offset(4)=982
	''plotvalues(1, 4)=startpressure
	''plotvalues(2, 4)=iif(plotvalues(2, 4)=0,rawpressure/2^12,plotvalues(2, 4)*0.96+(rawpressure/2^12)*0.04)
	''plotvalues(3, 4)=rawpressure/2^12
	
	
	'ranges(1)=180 'set the range to -90 to +90
	'plotvalues(1, 1)=outputRoll
	'plotvalues(2, 1)=outputPitch
	'plotvalues(3, 1)=outputYaw
	
	'ranges(2)=4
	'plotvalues(1, 2)=0 'dont draw the first "axis"
	'plotvalues(2, 2)=iif(plotvalues(2, 2)=0,outputAtt,plotvalues(2, 2)*0.9+outputAtt*0.1) 'set the value of the second "axis" on the second plot to a lowpass filtered altitude
	'plotvalues(3, 2)=outputAtt 'set the value of the third "axis" on the second plot to a non lowpass filtered altitude
	
	'nextplot 'draw all these values
	
loop while inkey="" 'do this while the user presses no key
end



'********************************************************************************************************************
'subs:

sub drawled(x as integer, y as integer, inten as ubyte)
	circle(x,y),20,&h010100*inten,,,,F 
	for i as integer = 1 to 10 ' draw some sparkels by using the trigonomic def. of a circle
		line(x+cos(360/10*i/180*3.1415)*30,y+sin(360/10*i/180*3.1415)*30)-(x+cos(360/10*i/180*3.1415)*50,y+sin(360/10*i/180*3.1415)*50),&h010100*int(inten^3/255^2)
	next i
	'draw the absolut value in the invented color the the led
	draw string (x-len(str(inten))*4+1,y-3),str(inten),&hFFFFFF xor &h010100*inten
end sub



