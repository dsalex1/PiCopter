#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <wiringPiI2C.h>
#include <math.h>
#include <fcntl.h>
#ifdef __unix__
   #include "includes/unixFunctions.hpp"
#else
   #include "includes/windowsFunctions.hpp"
#endif
#include "./libs/lsm6/LSM6.h"
#include "./libs/lis3/LIS3.h"
#include "./libs/lps25/LPS25.h"

/*
 *    0       1
 *   (CW)   (CCW)
 *     G     G
 *      G   G
 *       ---
 *       | |
 *       ---
 *      B   B
 *     B     B
 *  (CCW)   (CW)
 *    2      3
 *
 */
 
LIS3 mag;
LSM6 imu;
LPS alt;

//Gyroscope dps/LSB for 1000 dps full scale
#define GYRO_GAIN 35

//Accelerometer conversion factor for +/- 4g full scale
#define ACCEL_CONVERSION_FACTOR 0.122

#define MIN(a, b) (((a) < (b)) ? (a) : (b))
#define FRAME_LEN (1000000/60)
void sendData(int arg_count, ...) {
    putchar('<');
    va_list ap;
    va_start(ap, arg_count);
    for (int i = 0; i < arg_count; i++)
        printf("%08X", va_arg(ap, int));
    puts(">");
    fflush(stdout);
    va_end(ap);
}

void initPWM(){
	int fd = wiringPiI2CSetup(0x40);
    wiringPiI2CWriteReg8(fd,0x00,0x01); //set bit 4 from 1 to 0 to disable sleep mode, rest is default
    close(fd);
}

void setPWM_raw(int channel, int on_val, int off_val){
    int fd = wiringPiI2CSetup(0x40);
    wiringPiI2CWriteReg8(fd,0x06+4*channel, on_val & 0xFF);
    wiringPiI2CWriteReg8(fd,0x07+4*channel, on_val >> 8);
    wiringPiI2CWriteReg8(fd,0x08+4*channel, off_val & 0xFF);
    wiringPiI2CWriteReg8(fd,0x09+4*channel, off_val >> 8);
    close(fd);
}

void setPWM(int channel, int value){
    
    if (value>200) return; //safety line, dont go over 200 for now
    
    if (value<0) value=0;
    if (value>530) value=530;
    if (channel<0) channel=0;
    if (channel>15) channel=15;
    setPWM_raw(channel,0,888+value);//888 seems to be lowest with no motor movement, 889 is sligthly, 890 is slowly moving, at 1418 its maxed out
}

int* inputValues=new int[10];
void inputRecieved(char* inp){
    for (uint i=0;i<MIN(strlen(inp)/8,10);i++){
        char substr[9];
        memcpy( substr, &inp[i*8], 8 );
        substr[9] = '\0';
        sscanf(substr, "%X", &inputValues[i]);
    }
    //for (int i=0;i<3;i++)
    //    setPWM(i,inputValues[0]);
}

int inputIndex=-1;
char input[80];
void readInput(){
    char chr;
    while(read(STDIN_FILENO, &chr, 1) > 0){
        if (chr=='>') {
            input[inputIndex]='\0';
            inputIndex=-1;
            inputRecieved(input);
        }
        if (inputIndex!=-1) input[inputIndex++]=chr;
        if (chr=='<') inputIndex=0;
    }


}


int i=0;
void doFrame();
float standard_pressure;
int main()
{
    long before;
    long now;
    long delta;
    //make stdin nonblocking
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);

    if (!imu.init()){
        printf("Failed to detect and initialize IMU!\n");
        while (1);
    }
    imu.enableDefault();
    if (!mag.init()){
        printf("Failed to detect and initialize MAG!\n");
        while (1);
    }
    mag.enableDefault();
    if (!alt.init()){
        printf("Failed to detect and initialize ALT!\n");
        while (1);
    }
    alt.enableDefault();
    
    initPWM();
  
    for (int i=0;i<5;i++){
        standard_pressure+=alt.readPressureMillibars();
        delayMicroseconds(100*1000);
    }
    standard_pressure/=5;
  
    while(1) {
        before = micros();

        doFrame();

        now =  micros();
        delta = now - before;
        if(delta < FRAME_LEN){
            delayMicroseconds(FRAME_LEN-delta);
        }
    }
} 

float roll=0;
float pitch=0;
float yaw=0;
int lastTime=-1;
void getOrientation(float ax,float ay,float az,float gx,float gy,float gz,float mx,float my,float mz){
    if (lastTime==-1) lastTime=micros();
    float dT=(micros()-lastTime)*0.000001;
    
    float accRoll = atan2(ay, -az) * 180/3.1415 - 5.2;
    float accPitch = atan2(ax, -az) * 180/3.1415 -5.1;
	//combine it with gyro data and apply a lowpassfilter on it to get the best X/Y angle out of gyro and acc data
	roll=0.98*(roll-gx*dT+0.02*accRoll);
	pitch=0.98*(pitch+gy*dT+0.02*accPitch);
    
    float XH = mx * cos(pitch*3.1415/180) + mz * sin(pitch*3.1415/180);
    float YH = mx * sin(-roll*3.1415/180) * sin(pitch*3.1415/180) + my * cos(-roll*3.1415/180) - mz * sin(-roll*3.1415/180) * cos(pitch*3.1415/180);
    float magYaw = (atan2(YH, -XH) * 180 /3.1415);

    //printf("%f %f   %f %f   %f %f\n",mx,my,XH,YH,roll,pitch);


    if (magYaw-yaw>180 || magYaw-yaw<-180)
        yaw=-yaw;
        
    yaw=0.98*(yaw+gz*dT+0.02*magYaw);
    //yaw=atan2(mx,-my)* 180/3.1415;
    //yaw=magYaw;
    
    //sendData(7,int(yaw),int(atan2(mx,-my)* 180/3.1415),int(magYaw),0,0,0,0);
    
    
	lastTime=micros();
}

float height=0;
void doFrame(){
    readInput();
    

    imu.read();
    mag.read();
    float ax=imu.a.x*ACCEL_CONVERSION_FACTOR;
    float ay=imu.a.y*ACCEL_CONVERSION_FACTOR;
    float az=imu.a.z*ACCEL_CONVERSION_FACTOR;
    float gx=(imu.g.x*GYRO_GAIN-3700)*0.001;
    float gy=(imu.g.y*GYRO_GAIN+9750)*0.001;
    float gz=(imu.g.z*GYRO_GAIN+10450)*0.001;
    float mx=mag.m.x*0.89-1850;
    float my=mag.m.y*1   +2100;
    float mz=mag.m.z*1   -3700;
    
    float pressure=alt.readPressureMillibars();
    float temperature=alt.readTemperatureC();
    
    //low passfilter it
    //99% seems working <50cm noise and 3s sudden response time
    height=height*0.99+0.01*alt.pressureToAltitudeMeters(pressure,standard_pressure,temperature);
    
    getOrientation(ax,ay,az,gx,gy,gz,mx,my,mz);
    
    int* motorSpeeds= new int[4];
    
    motorSpeeds[0]=(50+roll-pitch)*inputValues[0]/50;
    motorSpeeds[1]=(50-roll-pitch)*inputValues[0]/50;
    motorSpeeds[2]=(50+roll+pitch)*inputValues[0]/50;
    motorSpeeds[3]=(50-roll+pitch)*inputValues[0]/50;
    
    
    for (int i=0;i<4;i++)
        setPWM(i,motorSpeeds[i]);
    
    sendData(7,int(roll),int(pitch),int(yaw),motorSpeeds[0],motorSpeeds[1],motorSpeeds[2],motorSpeeds[3]);
    i++;    
}









