''
''
'' wiringPi -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __wiringPi_bi__
#inclib "wiringPi"
#define __wiringPi_bi__

#define NUM_PINS 17
#define WPI_MODE_PINS 0
#define WPI_MODE_GPIO 1
#define WPI_MODE_GPIO_SYS 2
#define WPI_MODE_PHYS 3
#define WPI_MODE_PIFACE 4
#define WPI_MODE_UNINITIALISED -1
#define MODE_INPUT 0
#define MODE_OUTPUT 1
#define PWM_OUTPUT 2
#define GPIO_CLOCK 3
#define LOW 0
#define HIGH 1
#define PUD_OFF 0
#define PUD_DOWN 1
#define PUD_UP 2
#define PWM_MODE_MS 0
#define PWM_MODE_BAL 1
#define INT_EDGE_SETUP 0
#define INT_EDGE_FALLING 1
#define INT_EDGE_RISING 2
#define INT_EDGE_BOTH 3

#define GPIO_7 7
#define GPIO_11 0 
#define GPIO_13 2
#define GPIO_15 3
#define GPIO_12 1
#define GPIO_16 4
#define GPIO_18 5
#define GPIO_22 6

type wiringPiNodeStruct
	pinBase as integer
	pinMax as integer
	fd as integer
	data0 as uinteger
	data1 as uinteger
	data2 as uinteger
	data3 as uinteger
	pinMode as sub cdecl(byval as wiringPiNodeStruct ptr, byval as integer, byval as integer)
	pullUpDnControl as sub cdecl(byval as wiringPiNodeStruct ptr, byval as integer, byval as integer)
	digitalRead as function cdecl(byval as wiringPiNodeStruct ptr, byval as integer) as integer
	digitalWrite as sub cdecl(byval as wiringPiNodeStruct ptr, byval as integer, byval as integer)
	pwmWrite as sub cdecl(byval as wiringPiNodeStruct ptr, byval as integer, byval as integer)
	analogRead as function cdecl(byval as wiringPiNodeStruct ptr, byval as integer) as integer
	analogWrite as sub cdecl(byval as wiringPiNodeStruct ptr, byval as integer, byval as integer)
	next as wiringPiNodeStruct ptr
end type
extern wiringPiNodes alias "wiringPiNodes" as wiringPiNodeStruct ptr

declare function wiringPiFailure cdecl alias "wiringPiFailure" (byval fatal as integer, byval message as zstring ptr, ...) as integer
declare function wiringPiFindNode cdecl alias "wiringPiFindNode" (byval pin as integer) as wiringPiNodeStruct ptr
declare function wiringPiNewNode cdecl alias "wiringPiNewNode" (byval pinBase as integer, byval numPins as integer) as wiringPiNodeStruct ptr
declare function wiringPiSetup cdecl alias "wiringPiSetup" () as integer
declare function wiringPiSetupSys cdecl alias "wiringPiSetupSys" () as integer
declare function wiringPiSetupGpio cdecl alias "wiringPiSetupGpio" () as integer
declare function wiringPiSetupPhys cdecl alias "wiringPiSetupPhys" () as integer
declare sub pinModeAlt cdecl alias "pinModeAlt" (byval pin as integer, byval mode as integer)
declare sub pinMode cdecl alias "pinMode" (byval pin as integer, byval mode as integer)
declare sub pullUpDnControl cdecl alias "pullUpDnControl" (byval pin as integer, byval pud as integer)
declare function digitalRead cdecl alias "digitalRead" (byval pin as integer) as integer
declare sub digitalWrite cdecl alias "digitalWrite" (byval pin as integer, byval value as integer)
declare sub pwmWrite cdecl alias "pwmWrite" (byval pin as integer, byval value as integer)
declare function analogRead cdecl alias "analogRead" (byval pin as integer) as integer
declare sub analogWrite cdecl alias "analogWrite" (byval pin as integer, byval value as integer)
declare function wiringPiSetupPiFace cdecl alias "wiringPiSetupPiFace" () as integer
declare function wiringPiSetupPiFaceForGpioProg cdecl alias "wiringPiSetupPiFaceForGpioProg" () as integer
declare function piBoardRev cdecl alias "piBoardRev" () as integer
declare function wpiPinToGpio cdecl alias "wpiPinToGpio" (byval wpiPin as integer) as integer
declare function physPinToGpio cdecl alias "physPinToGpio" (byval physPin as integer) as integer
declare sub setPadDrive cdecl alias "setPadDrive" (byval group as integer, byval value as integer)
declare function getAlt cdecl alias "getAlt" (byval pin as integer) as integer
declare sub digitalWriteByte cdecl alias "digitalWriteByte" (byval value as integer)
declare sub pwmSetMode cdecl alias "pwmSetMode" (byval mode as integer)
declare sub pwmSetRange cdecl alias "pwmSetRange" (byval range as uinteger)
declare sub pwmSetClock cdecl alias "pwmSetClock" (byval divisor as integer)
declare sub gpioClockSet cdecl alias "gpioClockSet" (byval pin as integer, byval freq as integer)
declare function waitForInterrupt cdecl alias "waitForInterrupt" (byval pin as integer, byval mS as integer) as integer
declare function wiringPiISR cdecl alias "wiringPiISR" (byval pin as integer, byval mode as integer, byval function as sub cdecl()) as integer
declare function piThreadCreate cdecl alias "piThreadCreate" (byval fn as sub cdecl(byval as any ptr)) as integer
declare sub piLock cdecl alias "piLock" (byval key as integer)
declare sub piUnlock cdecl alias "piUnlock" (byval key as integer)
declare function piHiPri cdecl alias "piHiPri" (byval pri as integer) as integer
declare sub delay cdecl alias "delay" (byval howLong as uinteger)
declare sub delayMicroseconds cdecl alias "delayMicroseconds" (byval howLong as uinteger)
declare function millis cdecl alias "millis" () as uinteger
declare function micros cdecl alias "micros" () as uinteger

#endif
