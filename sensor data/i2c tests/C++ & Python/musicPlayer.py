from tkinter import *
from time import sleep
sys.path.insert(0, './includes')
from Plotter import Plotter,Plotter2D
from CPoller import *
import mido

plotting=True

def fToPwr(f):
    return round(pow(f/3.4,1/0.85))
    
def numberToF(m):
    while (m>70):
        m=m-12
    return pow(2,(m-69)/12)*440
    
def main():

    startPollingThread()
#    while (True):
#        inp=int(input())

#        print ("setting to "+str(fToPwr(numberToF(inp))))
#        writeOutput(fToPwr(numberToF(inp)))


    #sleep(4)
    #writeOutput(0,0,0,0)
    notes=[0,0,0,0]
    mid = mido.MidiFile('zelda.mid')
    for msg in mid.play():
        print(msg)
        if(msg.type=="note_on"):
            notes[int(msg.channel/4)]=msg.note
        if (msg.type=="note_off" and notes[int(msg.channel/4)]==msg.note):
            notes[int(msg.channel/4)]=0

        writeOutput(fToPwr(numberToF(notes[0])))

main()
