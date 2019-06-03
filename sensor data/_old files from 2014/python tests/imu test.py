#! usr/bin/python
import smbus
# 0x6d --> gyrometer L3GD60H
# 0x1d --> accelerometer/magnetometer LSM303D
# 0x5d --> Barometer
#
#

i2c=smbus.SMBus(1)

i2c.write_byte_data(0x6b,0x20,0x0F)
i2c.write_byte_data(0x6b,0x23,0x30)
i2c.write_byte_data(0x1d,0x20,0x57)
i2c.write_byte_data(0x1d,0x24,0xF0)
i2c.write_byte_data(0x1d,0x26,0x00)

from turtle import *
AccXPen=Turtle()
AccXPen.up()
AccXPen.back(400)
AccXPen.down()
AccXPen.pencolor(0.4,0,0)
AccXPen.speed(0)
AccYPen=Turtle()
AccYPen.up()
AccYPen.back(400)
AccYPen.down()
AccYPen.pencolor(0,0.4,0)
AccYPen.speed(0)

GyroXPen=Turtle()
GyroXPen.up()
GyroXPen.back(400)
GyroXPen.down()
GyroXPen.pencolor(1,0,0)
GyroXPen.speed(0)
GyroYPen=Turtle()
GyroYPen.up()
GyroYPen.back(400)
GyroYPen.down()
GyroYPen.pencolor(0,1,0)
GyroYPen.speed(0)
GyroZPen=Turtle()
GyroZPen.up()
GyroZPen.back(400)
GyroZPen.down()
GyroZPen.pencolor(0,0,1)
GyroZPen.speed(0)

MagXPen=Turtle()
MagXPen.up()
MagXPen.back(400)
MagXPen.down()
MagXPen.pencolor(1,0.75,0.75)
MagXPen.speed(0)
MagYPen=Turtle()
MagYPen.up()
MagYPen.back(400)
MagYPen.down()
MagYPen.pencolor(0.75,1,0.75)
MagYPen.speed(0)
MagZPen=Turtle()
MagZPen.up()
MagZPen.back(400)
MagZPen.down()
MagZPen.pencolor(0.75,0.75,1)
MagZPen.speed(0)

rawGyroX=0
rawGyroZ=0
rawGyroY=0
rawGyroTemp=0
rawAccX=0
rawAccY=0
rawMagX=0
rawMagZ=0
rawMagY=0
rawAccMagTemp=0
def binex(x): 
	return ''.join(x & (1 << i) and '1' or '0' for i in range(15,-1,-1)) 

while True:
	rawGyroX= i2c.read_byte_data(0x6b,0x28) | (i2c.read_byte_data(0x6b,0x29) << 8)
	if rawGyroX >> 15 == 1: 
		rawGyroX = -(0xFFFF-rawGyroX+1)
	rawGyroY= i2c.read_byte_data(0x6b,0x2A)  | (i2c.read_byte_data(0x6b,0x2B) << 8)
	if rawGyroY >> 15 == 1: 
		rawGyroY = -(0xFFFF-rawGyroY+1)
	rawGyroY=rawGyroY-38
	rawGyroZ= i2c.read_byte_data(0x6b,0x2C) | (i2c.read_byte_data(0x6b,0x2D) << 8)
	if rawGyroZ >> 15 == 1: 
		rawGyroZ = -(0xFFFF-rawGyroZ+1)
		
	rawGyroTemp= i2c.read_byte_data(0x6b,0x26)
	if rawGyroTemp >> 7 == 1: 
		rawGyroTemp = -(0xFF-rawGyroTemp+1)
		
	rawAccX= i2c.read_byte_data(0x1d,0x28) | (i2c.read_byte_data(0x1d,0x29) << 8)
	if rawAccX >> 15 == 1: 
		rawAccX = -(0xFFFF-rawAccX+1)
	rawAccY= i2c.read_byte_data(0x1d,0x2A)  | (i2c.read_byte_data(0x1d,0x2B) << 8)
	if rawAccY >> 15 == 1: 
		rawAccY = -(0xFFFF-rawAccY+1)
		
	rawMagX= i2c.read_byte_data(0x1d,0x08) | (i2c.read_byte_data(0x1d,0x09) << 8)	
	if rawMagX >> 15 == 1: 
		rawMagX = -(0xFFFF-rawMagX+1)
	rawMagY= i2c.read_byte_data(0x1d,0x0C)  | (i2c.read_byte_data(0x1d,0x0D) << 8)
	if rawMagY >> 15 == 1: 
		rawMagY = -(0xFFFF-rawMagY+1)
	rawMagY=rawMagY-38
	rawMagZ= i2c.read_byte_data(0x1d,0x0A) | (i2c.read_byte_data(0x1d,0x0B) << 8)
	if rawMagZ >> 15 == 1: 
		rawMagZ = -(0xFFFF-rawMagZ+1)
		
	rawAccMagTemp= i2c.read_byte_data(0x1d,0x05)  | (i2c.read_byte_data(0x1d,0x06) << 8)
	if rawAccMagTemp >> 11 == 1: 
		rawAccMagTemp = -(0x0FFF-rawAccMagTemp+1)
		
	AccXPen.sety(rawAccX/100)
	AccXPen.setx(AccXPen.xcor()+1)
	AccYPen.sety(rawAccY/100)
	AccYPen.setx(AccYPen.xcor()+1)
	
	print(str(i2c.read_byte_data(0x1d,0x28))+"  "+str(i2c.read_byte_data(0x1d,0x29)))
	#GyroXPen.sety(rawGyroX/5)
	#GyroXPen.setx(GyroXPen.xcor()+3)
	#GyroYPen.sety(rawGyroY/5)
	#GyroYPen.setx(GyroYPen.xcor()+3)
	#GyroZPen.sety(rawGyroZ/5)
	#GyroZPen.setx(GyroZPen.xcor()+3)
	
	#MagXPen.sety(rawMagX/10)
	#MagXPen.setx(MagXPen.xcor()+2)
	#MagYPen.sety(rawMagY/10)
	#MagYPen.setx(MagYPen.xcor()+2)
	#MagZPen.sety(rawMagZ/10)
	#MagZPen.setx(MagZPen.xcor()+2)


