#inclib "I2C" 'provide functions for reading/writing sensor data via I²C:
#inclib "wiringPi"
' addresses:
' 0x40  -  PWM Controller 
'declare sub write_I2C cdecl alias "write_I2C" (address as unsigned byte, reg as unsigned byte, value as unsigned byte )

'declare function read_I2C cdecl alias "read_I2C" (address as unsigned byte, reg as unsigned byte) as unsigned byte



sub setPWM(channel as integer, on_val as integer, off_val as integer)
    'Sets a single PWM channel
    write_I2C(&h40,6+4*channel, on_val and &hFF)
    write_I2C(&h40,7+4*channel, on_val shr 8)
    write_I2C(&h40,8+4*channel, off_val and &hFF)
    write_I2C(&h40,9+4*channel, off_val shr 8)
end sub

sub initPWM()
	write_I2C(&h40,&h00,&h01)
end sub
