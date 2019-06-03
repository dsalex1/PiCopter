#include "LPS25.h"
#include <wiringPiI2C.h>
#include <unistd.h>

// Defines ///////////////////////////////////////////////////////////

// The Arduino two-wire interface uses a 7-bit number for the address,
// and sets the last bit correctly based on reads and writes
#define SA0_LOW_ADDRESS  0b1011100
#define SA0_HIGH_ADDRESS 0b1011101

#define TEST_REG_NACK -1

#define LPS25H_WHO_ID   0xBD

// Constructors //////////////////////////////////////////////////////

LPS::LPS(void)
{
  _device = device_auto;
  
  // Pololu board pulls SA0 high, so default assumption is that it is
  // high
  address = SA0_HIGH_ADDRESS;
}

// Public Methods ////////////////////////////////////////////////////

// sets or detects device type and slave address; returns bool indicating success
bool LPS::init(deviceType device, byte sa0)
{
  _device = device_25H;
  device=device_25H;
  if(device==device_25H){
      translated_regs[-INTERRUPT_CFG] = LPS25H_INTERRUPT_CFG;
      translated_regs[-INT_SOURCE]    = LPS25H_INT_SOURCE;
      translated_regs[-THS_P_L]       = LPS25H_THS_P_L;
      translated_regs[-THS_P_H]       = LPS25H_THS_P_H;
      return true;
  }
  return false;
}

// turns on sensor and enables continuous output
void LPS::enableDefault(void)
{
  if (_device == device_25H)
  {
    // 0xB0 = 0b10110000
    // PD = 1 (active mode);  ODR = 011 (12.5 Hz pressure & temperature output data rate)
    writeReg(CTRL_REG1, 0xB0);
  }
}

// writes register
void LPS::writeReg(int reg, byte value){
  // if dummy register address, look up actual translated address (based on device type)
  if (reg < 0)
  {
    reg = translated_regs[-reg];
  }

  int fd = wiringPiI2CSetup(address);
  wiringPiI2CWriteReg8(fd, reg, value);
  close(fd);
}

// reads register
byte LPS::readReg(int reg)
{
  byte value;
  
  // if dummy register address, look up actual translated address (based on device type)
  if (reg < 0)
  {
    reg = translated_regs[-reg];
  }

  int fd = wiringPiI2CSetup(address);
  value=wiringPiI2CReadReg8 (fd, reg);
  close(fd);
  return value;
}

// reads pressure in millibars (mbar)/hectopascals (hPa)
float LPS::readPressureMillibars(void)
{
  return (float)readPressureRaw() / 4096;
}

// reads pressure in inches of mercury (inHg)
float LPS::readPressureInchesHg(void)
{
  return (float)readPressureRaw() / 138706.5;
}

// reads pressure and returns raw 24-bit sensor output
int32_t LPS::readPressureRaw(void)
{
  int fd = wiringPiI2CSetup(address);

  uint8_t pxl = wiringPiI2CReadReg8 (fd, PRESS_OUT_XL  );
  uint8_t pl  = wiringPiI2CReadReg8 (fd, PRESS_OUT_XL+1);
  uint8_t ph  = wiringPiI2CReadReg8 (fd, PRESS_OUT_XL+2);
  close(fd);
  // combine bytes
  return (int32_t)(int8_t)ph << 16 | (uint16_t)pl << 8 | pxl;
}

// reads temperature in degrees C
float LPS::readTemperatureC(void)
{
  return 42.5 + (float)readTemperatureRaw() / 480;
}

// reads temperature in degrees F
float LPS::readTemperatureF(void)
{
  return 108.5 + (float)readTemperatureRaw() / 480 * 1.8;
}

// reads temperature and returns raw 16-bit sensor output
int16_t LPS::readTemperatureRaw(void)
{
  int fd = wiringPiI2CSetup(address);

  uint8_t tl = wiringPiI2CReadReg8 (fd, TEMP_OUT_L  );
  uint8_t th = wiringPiI2CReadReg8 (fd, TEMP_OUT_L+1);
  close(fd);
  
  // combine bytes
  return (int16_t)(th << 8 | tl);
}

// converts pressure in mbar,standart pressure, and temperature
// to altitude in meters, using an axproximation of
// the barometric formular
// precise up to:
// 1000m  +-40m
// 100m   +-0.35m
// 15m    +-0.05m
float LPS::pressureToAltitudeMeters(float pressure_mbar, float standard_pressure,float temperature)
{
  return (28.467*temperature+7972)*standard_pressure/pressure_mbar-(28.467*temperature+7972);
}
// Private Methods ///////////////////////////////////////////////////

bool LPS::detectDeviceAndAddress(deviceType device, sa0State sa0)
{
  if (sa0 == sa0_auto || sa0 == sa0_high)
  {
    address = SA0_HIGH_ADDRESS;
    if (detectDevice(device)) return true;
  }
  if (sa0 == sa0_auto || sa0 == sa0_low)
  {
    address = SA0_LOW_ADDRESS;
    if (detectDevice(device)) return true;
  }

  return false;
}

bool LPS::detectDevice(deviceType device)
{
    _device = device_25H;
    return true;
}
