from tkinter import *
from time import sleep
sys.path.insert(0, './includes')
from Plotter import Plotter,Plotter2D
from CPoller import *

plotting=True
def main():

    startPollingThread()

    # set up the window
    root = Tk()
    root.title('controller')
    root.geometry('100x500')

    # make the interface
    sliderLabel = Label(root, text='Speed for PWM')
    sliderLabel.pack()

    def updatePWM(value):
        value=int(value)
        #print(value)
        writeOutput(value)
    def pausePlotting():
        global plotting
        endPollingThread()
        plotting=False
    def startPlotting():
        global plotting
        startPollingThread()
        plotting=True
    w2 = Button(root, text="Restart C Programm", command=startPlotting)
    w2.pack()

    w3 = Button(root, text="End C Programm", command=pausePlotting)
    w3.pack()

    w1 = Scale(root, from_=530, to=0, tickinterval=10,
               length=530, command=updatePWM)
    w1.set(0)
    w1.pack()

    #acc = Plotter((1200, 250), (-600, 250), (-1000, 1000), 3, 3)
    #gyro = Plotter((1200, 250), (-600, 0), (-90000, 90000), 3, 3)
    ori = Plotter((800, 360), (-400, -180-100), (-180, 180), 3, 3)
    speeds = Plotter((800, 200), (-400, 180-100), (-1000,1000), 4, 3)
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
            #baro.plot(inp[9:11])
            #print(inp)
            #mag2D.plot([(inp[7],inp[8]),(inp[6],inp[8]),(inp[6],inp[7])])
            #acc2D.plot([(inp[1],inp[2]),(inp[0],inp[2]),(inp[0],inp[1])])
            
            sleep(0.02)#sleep(1)
        root.update_idletasks()
        root.update()


main()
