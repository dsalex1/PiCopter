import subprocess
import sys
import threading
from textwrap import wrap
from operator import add
from time import sleep
from numpy import minimum
from numpy import maximum
import struct

threadRunning = False
inputCounter = 0
inputAccumulator = None
CProcess=None
minInput=None
maxInput=None

def pollCProgram(proc):
    global inputAccumulator, inputCounter, threadRunning,CProcess,minInput,maxInput

    CProcess=proc
    threadRunning = True
    print("thread started")
    while threadRunning:
        inp = readMsg(proc)
        # parse as 8 hex digits long ints
        inp= wrap(inp, 8)
        inp = list((map(lambda s: struct.unpack('>i', bytes.fromhex(s))[0] , inp)))
        #print (str(inp))
        
        if (minInput == None):
            minInput=inp
            maxInput=inp
        minInput = minimum(minInput, inp)
        maxInput = maximum(maxInput, inp)
        
        if (inputCounter == 0):
            inputAccumulator = inp
        else:
            # add together
            inputAccumulator = list(map(add, inputAccumulator, inp))
        inputCounter = inputCounter + 1
    print("thread exited")
    sys.exit()

def getMinMax():
    return (minInput,maxInput)
    
def getCurrentInput():
    global inputAccumulator, inputCounter
    if (inputCounter == 0):
        if (inputAccumulator!=None):
            return inputAccumulator
        else:
            return (0,0,0,0,0,0,0,0,0,0)
    average = [x / inputCounter for x in inputAccumulator]
    inputAccumulator = average
    inputCounter = 0
    return average
    
def writeOutput(*arg):
    string=""
    for i in arg:
        string=string+struct.pack(">i",int(i)).hex()
    CProcess.stdin.write(bytes("<"+string+">","ascii"))
    CProcess.stdin.flush()

def readMsg(proc):
    output = ""
    while (proc.stdout.read(1).decode('cp437') != "<"):
        pass
    char = ""
    while (char != ">"):
        output += char
        char = proc.stdout.read(1).decode('cp437')
    return output


CProc = None
CThread = None


def endPollingThread():
    global CProc, CThread, threadRunning
    threadRunning = False
    CThread.join()
    CProc.kill()
    CProc = None


def startPollingThread():
    global CProc, CThread

    if(CProc != None):
        endPollingThread()
    CProc = subprocess.Popen(["/home/pi/Desktop/quadrocopter/sensor data/i2c tests/C++ & Python/main", ""],
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    CThread = threading.Thread(target=pollCProgram, args=[CProc])
    CThread.start()
