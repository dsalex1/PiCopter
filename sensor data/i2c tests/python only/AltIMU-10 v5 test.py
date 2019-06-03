#from altimu10v5 import IMU
from time import sleep
from smbus import SMBus

#imu = IMU()
#imu.enable()

i2c=SMBus(1)


    

def setPWM_raw(channel, on_val, off_val):
    i2c.write_byte_data(0x40,0x6+4*channel, on_val & 0xFF)
    i2c.write_byte_data(0x40,0x7+4*channel, on_val >> 8)
    i2c.write_byte_data(0x40,0x8+4*channel, off_val & 0xFF)
    i2c.write_byte_data(0x40,0x9+4*channel, off_val >> 8)

def setPWM(channel,value):
    if value<0: value=0
    if value>100: value=100
    if channel<0: channel=0
    if channel>15: channel=15
    setPWM_raw(channel,0,int(4095*value/100))
    
def initPWM():
	i2c.write_byte_data(0x40,0x00,0x01) #set bit 4 from 1 to 0 to disable sleep mode, rest is default


initPWM()




from tkinter import *
from turtle import Turtle, Screen

class Plotter:

    COLORS = ["red", "green", "blue", "magenta", "orange", "cyan"]

    def __init__(self, size, pos, ranges, graphs, step):
        self.width = size[0] - 30

        self.height = size[1]-20
        self.min = ranges[0]
        self.max = ranges[1]
        self.x = pos[0] + 30
        self.y = pos[1] + 10
        self.graphs = graphs
        self.pens = []
        self.i = self.width
        self.step = step
        for i in range(graphs):
            pen = Turtle()
            pen.up()
            pen.speed(0)
            pen.color(self.COLORS[i])
            pen.width(1)
            pen.hideturtle()
            self.pens.append(pen)
        guiPen = Turtle()
        guiPen.up()
        guiPen.getscreen().tracer(0, 0)
        guiPen.hideturtle()
        guiPen.speed(0)
        guiPen.color("black")
        guiPen.setpos(self.x, self.y)
        guiPen.down()
        guiPen.setpos(self.x + self.width, self.y)
        guiPen.setpos(self.x+self.width, self.y+self.height)
        guiPen.setpos(self.x, self.y+self.height)
        guiPen.setpos(self.x, self.y)
        guiPen.up()

        for i in range(self.width / 2):
            guiPen.setpos(self.x + i * 2+1, self.y + self.height / 2)
            guiPen.dot(2)
        for i in range(self.width / 4):
            guiPen.setpos(self.x + i * 4+2, self.y + self.height * 0.75)
            guiPen.dot(2)
        for i in range(self.width / 4):
            guiPen.setpos(self.x + i * 4+2, self.y + self.height * 0.25)
            guiPen.dot(2)

        for i in range(5):
            guiPen.setpos(self.x - 2, self.y+self.height*i/4-7)
            guiPen.write(str((self.max-self.min)*i/4+self.min), align="right")

        guiPen.getscreen().tracer(1, 0)

        self.numPen = Turtle()
        self.numPen.up()
        self.numPen.hideturtle()
        self.numPen.speed(0)
        self.numPen = [self.numPen, self.numPen.clone()]

    def plot(self, data):
        self.i = self.i + self.step

        if (self.i > self.width):  # reset
            print("reset")
            self.i = 0
            for i in range(len(data)):
                self.pens[i].clear()
                self.pens[i].up()
                self.pens[i].setpos(self.getCoordinates(data[i]))
                self.pens[i].down()

        for i in range(len(data)):
            self.pens[i].setpos(self.getCoordinates(data[i]))
            numPen = self.numPen[self.i/self.step % 2]
            numPen.setpos(self.x + self.width, self.y +
                         self.height - i * 20-20)
            numPen.color(self.COLORS[i])
            numPen.write(str(data[i]), align="right")

        self.numPen[(self.i/self.step + 1) %
                   2].clear()  # fancy double buffering

    def getCoordinates(self, value):
        return (self.i+self.x, (0.0+value-self.min)/(self.max-self.min)*self.height+self.y)


# set up the window
root = Tk()
root.title('controller')
root.geometry('100x500')

# make the interface
sliderLabel = Label(root, text='Speed for PWM')
sliderLabel.pack()


PWMValue=0
def updatePWM(value):
    global PWMValue
    value=int(value)
    setPWM(0,value)
    PWMValue=value


w1 = Scale(root, from_=100, to=0, tickinterval=10,
           length=600, command=updatePWM)
w1.set(0)
w1.pack()

#acc = Plotter((800, 200), (-400, 200), (-180, 180), 2, 5)
#gyro = Plotter((800, 200), (-400, 0), (-180, 180), 3, 5)
#mag = Plotter((800, 200), (-400, -200), (-5000, 5000), 3, 5)
#baroPWM = Plotter((800, 200), (-400, -400), (4149000, 4153000), 2, 5)

while (True):
    #rawAcc=imu.lsm6ds33.get_accelerometer_angles()
    #acc.plot([rawAcc[0], rawAcc[1]])

    #rawGyro=imu.lsm6ds33.get_gyro_angular_velocity()
    #gyro.plot([rawGyro[0],rawGyro[1],rawGyro[2]])
    
    #rawMag=imu.lis3mdl.get_magnetometer_raw()
    #mag.plot([rawMag[0], rawMag[1],rawMag[2]])

    #rawBaro=imu.lps25h.get_barometer_raw()
    #baroPWM.plot([rawBaro,PWMValue*40+4149000])
    
    mainloop()
