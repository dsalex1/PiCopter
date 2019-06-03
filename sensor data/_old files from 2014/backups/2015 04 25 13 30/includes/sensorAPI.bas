#inclib "I2C" 'provide functions for reading/writing sensor data via I²C:
declare sub write_I2C cdecl alias "write_I2C" (address as unsigned byte, reg as unsigned byte, value as unsigned byte )
declare function read_I2C cdecl alias "read_I2C" (address as unsigned byte, reg as unsigned byte) as unsigned byte

type orientation
	roll as single =0
	pitch as single =0
	yaw as single =0
end type

type position
	longitude as single =0
	latitude as single =0
	altitude as single =0
end type


declare sub initsensors
declare sub getsensorvalues
declare function getorientation as orientation
declare function getposition as position

'variables to store raw readings from the sensors
dim shared as integer rawpressure=0

dim shared as short rawGyroX=0
dim shared as short rawGyroZ=0
dim shared as short rawGyroY=0
dim shared as byte  rawGyroTemp=0

dim shared as short rawAccX=0
dim shared as short rawAccY=0
dim shared as short rawAccZ=0

dim shared as short rawMagX=0
dim shared as short rawMagZ=0
dim shared as short rawMagY=0
dim shared as short rawAccMagTemp=0

dim shared as orientation last_orientation
dim shared as single startpressure=0

dim shared as double starttime

sub initsensors
	'read the sensor documentation! #i_dont_wanna_explain_this
	write_I2C(&h6b,&h20,&h0F)
	write_I2C(&h6b,&h23,&h30)
	write_I2C(&h1d,&h20,&h57)
	write_I2C(&h1d,&h24,&hF0)
	write_I2C(&h1d,&h26,&h00)
	write_I2C(&h5d,&h20,&hc0)
	starttime=timer
end sub 


sub getsensorvalues
	'read the values out of the registers and do some bitshifting and complementing on it #i_dont_wanna_explain_this
	'read the sensor documentation for further details
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


function getorientation as orientation
	dim as orientation o
	dim as single accXangle=0,accYangle=0
	
	getsensorvalues 'getting the values needed
	
	'doing some math on the acc. data to get rawangles from it
	accxangle=atn(rawAccY/sqr(rawAccX^2+rawAccZ^2))/3.1415*180
	accYangle=atn(-rawAccx/rawAccZ)/3.1415*180
	
	'combine it with gyro data and apply a lowpassfilter on it to get the best X/Y angle out of gyro and acc data
	o.roll=0.98*(last_orientation.Roll-rawGyroX/2^16*120)+0.02*accxangle
	o.pitch=0.98*(last_orientation.Pitch+rawGyroY/2^16*120)+0.02*accYangle
	last_orientation=o
	'calculate yaw/z angle by using the magnetometer - doesn't works soo well..
	if (rawMagZ-300)/2000/0.6>1 then
		o.Yaw=asin(1)/3.1415*180
	elseif (rawMagZ-300)/2000/0.6<-1 then 
		o.Yaw=asin(-1)/3.1415*180
	else
		o.Yaw=asin((rawMagZ-300)/2000/0.6)/3.1415*180
	end if
	return o
end function


function getposition() as position
	dim as position p
	p.longitude=0
	p.latitude=0
	'getting altitude:
	'for the first 10 sec calculate the middle of all pressure values to get a standard-pressure then return altitude
	if timer-starttime<10 then 
		startpressure=iif(startpressure=0,rawpressure/2^12,startpressure*0.98+(rawpressure/2^12)*0.02)
	else
		p.altitude=(rawpressure/2^12-startpressure)*9.144
	end if
	return p
end function
