'#define Right_LED GPIO_11
'#define Back_LED GPIO_16
'#define Front_LED GPIO_22
'#define Left_LED GPIO_23

#include once "includes/PID_Controller.bas" 'provide PID controller function PID(...)  
#include once "includes/sensorAPI.bas" 'provide sensor communication getorientaiton()... 
#include once "includes/plotAPI.bas"
#include once "includes/controlsAPI.bas"
#include once "includes/PWMApi.bas"

declare function wiringPiSetup cdecl alias "wiringPiSetup" as integer
declare sub pinMode cdecl (pin as integer, mode as integer) 
declare function digitalRead cdecl alias "digitalRead" ( pin as integer) as integer
wiringPiSetup

' sensor addresses:
' &h6d --> gyrometer L3GD60H
' &h1d --> accelerometer/magnetometer LSM303D
' &h5d --> Barometer


screenres 1500,800,32

declare sub sensorIO
declare sub handlePlots

'loading the picoper image and "store it in "picopter"
dim shared as any ptr picopter
picopter=imagecreate(382,382)
bload exepath+ "/data_files/picopter.bmp",picopter



'variables to store calculated values like orientation/altitude/motorspeeds
dim shared as orientation curentOrientation
dim shared as position curentPosition
dim shared as motorspeeds curentMotorSpeeds
dim shared as userinput curentuserinput

'*************************************************************************************************************************

'prepearing: initialize things
initsensors()
initControls()
initPWM()

put(1060,60),picopter
	

dim shared as plot accelerometer_raw=plot(3,0,"accelerometer raw","g")
dim shared as plot gyroscope_raw=plot(720,0,"gyroscope raw",chr(248)+"/s") ' chr(248) = °
dim shared as plot magnetometer_raw=plot(4,0,"magnetometer raw ","gauss")
dim shared as plot pressure_raw=plot(1,1000,"pressure raw","mbar")
dim shared as plot fused_angles=plot(180,0,"fused angles",chr(248))
dim shared as plot altitude=plot(4,0,"altitude","m")
dim shared as plot user1=plot(2,0,"user input 1","")
dim shared as plot user2=plot(2,0,"user input 2","")
startplot(1000,800)

'*************************************************************************************************************************
'main loop: getting sensor values; calculate orientationa and altitude ; plot sensor values and draw "simulated" picopter 
do

	sensorIO()
		
	curentuserinput=getuserinput
	
	curentmotorspeeds=PID(,,,curentOrientation.Roll,curentOrientation.Pitch,0,curentuserinput.roll,curentuserinput.pitch,curentuserinput.yaw,curentuserinput.power*0+1)  'let the PID controller calculate the motorspeeds and store them in motorspeeds (range 0 to 100)

	
	' "simulate" the picopter by drawing leds in the according brightniss
	drawled(1251+cos(3.1415/3*6)*158,251+sin(3.1415/3*6)*158,curentmotorspeeds.firs)
	drawled(1251+cos(3.1415/3*1)*158,251+sin(3.1415/3*1)*158,curentmotorspeeds.seco)
	drawled(1251+cos(3.1415/3*2)*158,251+sin(3.1415/3*2)*158,curentmotorspeeds.thir)
	drawled(1251+cos(3.1415/3*3)*158,251+sin(3.1415/3*3)*158,curentmotorspeeds.fort)
	drawled(1251+cos(3.1415/3*4)*158,251+sin(3.1415/3*4)*158,curentmotorspeeds.fivt)
	drawled(1251+cos(3.1415/3*5)*158,251+sin(3.1415/3*5)*158,curentmotorspeeds.sixt)
	'set the real leds
	setPWM(0,0,(2^12-2)/(1+1.4^(-curentmotorspeeds.firs+50))+1)
	setPWM(1,0,(2^12-2)/(1+1.4^(-curentmotorspeeds.seco+50))+1)
	setPWM(2,0,(2^12-2)/(1+1.4^(-curentmotorspeeds.thir+50))+1)
	setPWM(3,0,(2^12-2)/(1+1.4^(-curentmotorspeeds.fort+50))+1)
	setPWM(4,0,(2^12-2)/(1+1.4^(-curentmotorspeeds.fivt+50))+1)
	setPWM(5,0,(2^12-2)/(1+1.4^(-curentmotorspeeds.sixt+50))+1)
	locate 3,3
	
	print 1/(1+1.4^(-curentmotorspeeds.firs+50))
	handlePlots()
	
	if digitalRead(3)=0 then 
	setPWM(0,0,0)
	setPWM(1,0,0)
	setPWM(2,0,0)
	setPWM(3,0,0)
	setPWM(4,0,0)
	setPWM(5,0,0)
	shell "sudo halt"
	do:loop
	end if
	
loop while inkey="" 'do this while the user presses no key
end



'********************************************************************************************************************
'subs:

sub sensorIO

	readSensorValues 'getting all raw values
	
	curentOrientation=getOrientation()
	
	curentPosition=getPosition() 'currently only altitude	
	
end sub


sub handlePlots
	
	'plot the values:
	
	accelerometer_raw.setvalues(rawAccX/2^15*2, rawAccY/2^15*2, rawAccZ/2^15*2)
	
	gyroscope_raw.setvalues(rawGyroX/2^15*2000, rawGyroY/2^15*2000, rawGyroZ/2^15*2000)
	
	magnetometer_raw.setvalues(rawMagX/2^12*1.3,rawMagY/2^12*1.3, rawMagZ/2^12*1.39)
	
	pressure_raw.setvalues(startpressure,iif(pressure_raw.value2=0,rawpressure/2^12,pressure_raw.value2*0.96+(rawpressure/2^12)*0.04),rawpressure/2^12)
	if curentPosition.altitude<>0 then pressure_raw.setoffset(getStandardPressure)
	
	fused_angles.setvalues(curentOrientation.Roll, curentOrientation.Pitch, curentOrientation.Yaw)
	
	altitude.setvalues(0, iif(altitude.value2=0,curentPosition.altitude,altitude.value2*0.9+curentPosition.altitude*0.1), curentPosition.altitude)
	
	user1.setvalues(curentuserinput.yaw,curentuserinput.power,0)
	
	user2.setvalues(curentuserinput.roll,curentuserinput.pitch,0)
	
	redrawplot
	
end sub


sub drawled(x as integer, y as integer, inten as ubyte)
	circle(x,y),20,&h010100*int(inten*2.55),,,,F 
	for i as integer = 1 to 10 ' draw some sparkels by using the trigonomic def. of a circle
		line(x+cos(360/10*i/180*3.1415)*30,y+sin(360/10*i/180*3.1415)*30)-(x+cos(360/10*i/180*3.1415)*50,y+sin(360/10*i/180*3.1415)*50),&h010100*int((inten*2.55)^3/255^2)
	next i
	'draw the absolut value in the invented color the the led
	draw string (x-len(str((inten)))*4+1,y-3),str((inten)),&hFFFFFF xor &h010100*int(inten*2.55)
end sub

