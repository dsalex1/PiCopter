#inclib "I2C" 'provide functions for reading/writing sensor data via I²C:
#inclib "wiringPi"
' addresses:
' 0x40  -  PWM Controller 
screenres 400,400

declare sub write_I2C cdecl alias "write_I2C" (address as unsigned byte, reg as unsigned byte, value as unsigned byte )

declare function read_I2C cdecl alias "read_I2C" (address as unsigned byte, reg as unsigned byte) as unsigned byte


dim shared as double t
sub setPWM(channel as integer, on_val as integer, off_val as integer)
    'Sets a single PWM channel
    locate 1,1
    t=timer
    write_I2C(&h40,6+4*channel, on_val and &hFF)
    print timer-t
    write_I2C(&h40,7+4*channel, on_val shr 8)
    write_I2C(&h40,8+4*channel, off_val and &hFF)
    write_I2C(&h40,9+4*channel, off_val shr 8)
    print timer-t
end sub

dim as integer x,y

do while inkey=""
	getmouse(x,y)
	setPWM(0,0, (y-100)*4)
loop
   

 
