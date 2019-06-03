#include <stdio.h>
#include <stdlib.h>
#include <wiringPiI2C.h>
#include <unistd.h>

void write_I2C(unsigned char address,unsigned char reg,unsigned char value){
	int fd=wiringPiI2CSetup (address);
	wiringPiI2CWriteReg8(fd,reg,value);
	close(fd);
}
unsigned char read_I2C(unsigned char address,unsigned char reg){
	int fd=wiringPiI2CSetup (address);
	return wiringPiI2CReadReg8(fd,reg);
	close(fd);
}

