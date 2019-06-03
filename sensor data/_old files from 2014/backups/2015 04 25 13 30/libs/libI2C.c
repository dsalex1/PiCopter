#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>

#define MAG_ADDRESS        (0x1D)
#define LSM303_WHO_AM_I_M  (0x0F)
void write_I2C(unsigned char address,unsigned char reg,unsigned char value){
	char addtmp[3];
    char regtmp[3];
    sprintf(addtmp, "%X",address);
    sprintf(regtmp, "%X",reg);
    char result[32];
	sprintf(result,"%s%s%s%s%s%d","sudo i2cset -y 1 0x",addtmp," 0x",regtmp," ",value);
	system(result);
}
unsigned char read_I2C(unsigned char address,unsigned char reg){
	char buf[10];
    const char * devName = "/dev/i2c-1";

    // Open up the I2C bus
    int file = open(devName, O_RDWR);
    if (file == -1)
    {
        perror(devName);
        exit(1);
    }

    // Specify the address of the slave device.
    if (ioctl(file, I2C_SLAVE, address) < 0)
    {
        perror("Failed to acquire bus access and/or talk to slave");
        exit(1);
    }

    // Write a byte to the slave.
    buf[0] = reg;
    if (write(file, buf, 1) != 1)
    {
        perror("Failed to write to the i2c bus");
        exit(1);
    }

    // Read a byte from the slave.
    if (read(file,buf,1) != 1)
    {
        perror("Failed to read from the i2c bus");
        exit(1);
    }
	close(file);
    return buf[0];

}
