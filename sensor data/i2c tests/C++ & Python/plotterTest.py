from tkinter import *
from time import sleep
sys.path.insert(0, './includes')
from Plotter import getTurtleScreen,turtleOnkey,Plotter,Plotter2D
from CPoller import *
import os

from flask import Flask, request
import threading
import logging


app = Flask(__name__, static_url_path='')
@app.route("/")
def index():
    return app.send_static_file("index.html")

P=0
D=0

roll = 0
pitch = 0
power = 0
yaw = 0
@app.route("/input")
def input():
    global roll, pitch, power, yaw,scalebarvalue
    roll = float(request.args.get("xl"))*300
    pitch = float(request.args.get("yl"))*300
    yaw = float(request.args.get("xr"))*100
    power = float(request.args.get("yr"))*100
    writeOutput(int(roll),int(pitch),int(yaw),int(power))
    return ""

def startServer():
    app.run(host='0.0.0.0')
threading.Thread(target=startServer).start()
def disLog():
    log = logging.getLogger('werkzeug')
    log.setLevel(logging.ERROR)
app.before_first_request(disLog)



scalebarvalue=0
scalebar=None

exiting=False
plotting=True
def main():
    global scalebar

    startPollingThread()

    # set up the window
    root = Tk()
    root.title('controller')
    root.geometry('100x500')

    # make the interface
    sliderLabel = Label(root, text='Speed for PWM')
    sliderLabel.pack()

    def close():
        global exiting
        exiting=True
        

    getTurtleScreen()._root.protocol("WM_DELETE_WINDOW", close)
    turtleOnkey(close, "Up")
    root.protocol("WM_DELETE_WINDOW", close)
    
    def updateP(value):
        global P
        P=int(value)
        updatePWM(power)
    def updateD(value):
        global D
        D=int(value)
        updatePWM(power)
        
    def updatePWM(value):
        global power
        value=int(value)
        #print(value)
        power=value
        writeOutput(int(roll),int(pitch),int(yaw),value,P,D)
    def pausePlotting():
        global plotting
        endPollingThread()
        plotting=False
    def startPlotting():
        global plotting
        startPollingThread()
        plotting=True
    w2 = Button(root, text="Close", command=close)
    w2.pack()
    
    w2 = Button(root, text="Restart C Programm", command=startPlotting)
    w2.pack()

    w3 = Button(root, text="End C Programm", command=pausePlotting)
    w3.pack()

    scalebar = Scale(root, from_=730, to=0, tickinterval=10,
               length=730, command=updatePWM)
    scalebar.set(0)
    scalebar.pack(side=LEFT)
    
    PScale = Scale(root, from_=0, to=50, tickinterval=1,
               length=500, command=updateP)
    PScale.set(10)
    PScale.pack(side=LEFT)

    DScale = Scale(root, from_=0, to=50, tickinterval=1,
               length=500, command=updateD)
    DScale.set(2)
    DScale.pack(side=LEFT)
    
    #acc = Plotter((1200, 250), (-600, 250), (-1000, 1000), 3, 3)
    #gyro = Plotter((1200, 250), (-600, 0), (-90000, 90000), 3, 3)
    ori = Plotter((800, 360), (-400, -180-100-100), (-100, 100), 3, 3)
    speeds = Plotter((800, 200), (-400, 180-100-100), (-0,300), 4, 3)
    inputs = Plotter((800, 200), (-400, 180), (-100,100), 4, 3)
    #baro = Plotter((1200, 250), (-600, -500), (-1000,1000), 2, 3)
    #mag2D=Plotter2D((300, 300), (0, -160), (-4000, 4000), 3, 3)
    #acc2D=Plotter2D((300, 300), (0, 160), (-1000, 1000), 3, 3)
   

    while (True):
        if(plotting):
            inp = getCurrentInput()
            #acc.plot(inp[0:3])
            #gyro.plot(inp[3:6])
            ori.plot(inp[0:3])
            speeds.plot(inp[3:7])
            inputs.plot(inp[7:11])
            #baro.plot(inp[9:11])
            #print(inp)
            #mag2D.plot([(inp[7],inp[8]),(inp[6],inp[8]),(inp[6],inp[7])])
            #acc2D.plot([(inp[1],inp[2]),(inp[0],inp[2]),(inp[0],inp[1])])
            sleep(0.02)#sleep(1)
            
        if (exiting==True):
            getTurtleScreen()._root.destroy()
            root.destroy()
            break
        scalebar.set(int(power))
        root.update_idletasks()
        root.update()

    #cleanup 
    writeOutput(0)
    sleep(0.2)
    endPollingThread()
    os.system('kill %d' % os.getpid())#idc, just kill this script
    sys.exit(0)
        
main()



