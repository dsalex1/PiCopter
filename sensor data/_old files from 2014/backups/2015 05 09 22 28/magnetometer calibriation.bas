'magnetometer calibration
#include "includes/sensorAPI.bas"

screenres 800,800,32
line (400,0)-(400,800)
line (0,400)-(800,400)
dim as vector3d magfield
initsensors
do
	readsensorvalues
	
	dim as orientation ot=getorientation
	magfield = getMagFieldVec
	magfield.x=magfield.x-450
	magfield.y=magfield.y-475
	magfield.z=magfield.z-250
	
	dim as vector3d untildetmag
	untildetmag.x=magfield.x*cos(ot.roll/180*3.1415)+magfield.y*sin(ot.pitch/180*3.1415)-magfield.z*cos(ot.roll/180*3.1415)*sin(ot.roll/180*3.1415)
	untildetmag.y=magfield.y*cos(ot.roll/180*3.1415)+magfield.z*sin(ot.roll/180*3.1415)
	
	untildetmag.z= atan2(-untildetmag.y,untildetmag.x)*180/3.1415
	pset((magfield.x)/35*2+200,(magfield.y)/35*2+200)
	pset((magfield.x)/35*2+600,(magfield.z)/35*2+200)
	pset((magfield.y)/35*2+200,(magfield.z)/35*2+600)
	pset((rnd*350+425),-(magfield.x^2+magfield.y^2+magfield.z^2)^0.5/35*4+800)
	line(0,0)-(50,50),0,BF
	locate 1,1
	print ot.roll,ot.pitch
	print magfield.x, magfield.y, magfield.z
	print untildetmag.x,untildetmag.y, untildetmag.z
	print untildetmag.z,atan2(-magfield.y,magfield.x)*180/3.1415
loop while inkey = ""
