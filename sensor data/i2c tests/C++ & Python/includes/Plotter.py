from turtle import Turtle, Screen, getscreen,onkey
import time

def getTurtleScreen():
    return getscreen()
    
def turtleOnkey(fun, key):
    Screen().onkey(fun,key)

class Plotter:

    COLORS = ["red", "green", "blue", "magenta", "orange", "cyan"]

    def __init__(self, size, pos, ranges, graphs, step):
        self.width = size[0] - 30

        self.height = size[1]-30
        self.min = ranges[0]
        self.max = ranges[1]
        self.x = pos[0] + 30
        self.y = pos[1]
        self.graphs = graphs
        self.pens = []
        self.i = self.width
        self.step = step
        self.lastTime = -1
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

        for i in range(int(self.width / 2)):
            guiPen.setpos(self.x + i * 2+1, self.y + self.height / 2)
            guiPen.dot(2)
        for i in range(int(self.width / 4)):
            guiPen.setpos(self.x + i * 4+2, self.y + self.height * 0.75)
            guiPen.dot(2)
        for i in range(int(self.width / 4)):
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
        sets = min(len(data), self.graphs)
        self.i = self.i + int(self.step*(time.time()*1000-self.lastTime)/50)
        self.lastTime = time.time() * 1000
        if (self.i > self.width):  # reset
            self.i = 0
            for i in range(sets):
                self.pens[i].clear()
                self.pens[i].up()
                self.pens[i].setpos(self.getCoordinates(data[i]))
                self.pens[i].down()

        for i in range(sets):
            self.pens[i].setpos(self.getCoordinates(data[i]))
            numPen = self.numPen[int(self.i/self.step % 2)]
            numPen.setpos(self.x + self.width, self.y + self.height - i * 20-20)
            numPen.color(self.COLORS[i])
            numPen.write(int(data[i]), align="right")

        self.numPen[int(self.i/self.step + 1) % 2].clear()  # fancy double buffering

    def getCoordinates(self, value):
        return (self.i+self.x, (0.0+value-self.min)/(self.max-self.min)*self.height+self.y)

class Plotter2D:

    COLORS = ["red", "green", "blue", "magenta", "orange", "cyan"]

    def __init__(self, size, pos, ranges, graphs, step):
        self.width = size[0] - 10

        self.height = size[1]-10
        self.min = ranges[0]
        self.max = ranges[1]
        self.x = pos[0] 
        self.y = pos[1]
        self.graphs = graphs
        self.pens = []
        self.i = self.width
        self.step = step
        self.lastTime = -1
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
        guiPen.setpos(self.x - self.width/2, self.y)
        guiPen.setpos(self.x + self.width/2+10, self.y)
        guiPen.setpos(self.x + self.width/2+5, self.y-5)
        guiPen.setpos(self.x + self.width/2+10, self.y)
        guiPen.setpos(self.x + self.width/2+5, self.y+5)
        guiPen.up()

        guiPen.setpos(self.x   , self.y   - self.height/2)
        guiPen.down()
        guiPen.setpos(self.x   , self.y+10 + self.height/2)
        guiPen.setpos(self.x +5, self.y+5   + self.height/2)
        guiPen.setpos(self.x   , self.y+10 + self.height/2)
        guiPen.setpos(self.x -5, self.y+5  + self.height/2)
        guiPen.up()

        for i in range(5):
            guiPen.setpos(self.x - self.width/2+i/4*self.width, self.y-5)
            guiPen.down()
            guiPen.setpos(self.x - self.width/2+i/4*self.width, self.y+5)
            guiPen.up()
            guiPen.write(str((self.max-self.min)*i/4+self.min), align="center")
            
            guiPen.setpos(self.x-5,self.y - self.height/2+i/4*self.height)
            guiPen.down()
            guiPen.setpos(self.x+5,self.y - self.height/2+i/4*self.height)
            guiPen.up()
            guiPen.setpos(self.x+10,self.y - self.height/2+i/4*self.height-7)
            guiPen.write(str((self.max-self.min)*i/4+self.min), align="left")


        guiPen.getscreen().tracer(1, 0)

        self.numPen = Turtle()
        self.numPen.up()
        self.numPen.hideturtle()
        self.numPen.speed(0)
        self.numPen = [self.numPen, self.numPen.clone()]


    def clear(self):
        self.i = 0
        for i in range(len(self.pens)):
            self.pens[i].clear()
            
    def plot(self, data):
        sets = min(len(data), self.graphs)
        self.i = self.i + int(self.step*(time.time()*1000-self.lastTime)/50)
        self.lastTime = time.time() * 1000

        for i in range(sets):
            self.pens[i].setpos(self.getCoordinates(data[i][0],data[i][1]))
            self.pens[i].dot(3)
            # numPen = self.numPen[self.i/self.step % 2]
            # numPen.setpos(self.x + self.width, self.y +
            #              self.height - i * 20-20)
            # numPen.color(self.COLORS[i])
            # numPen.write(str(data[i]), align="right")

        # self.numPen[(self.i/self.step + 1) %
        #            2].clear()  # fancy double buffering

    def getCoordinates(self, valuex,valuey):
        return ((0.0+valuex-self.min)/(self.max-self.min)*self.width-0.5*self.width+self.x, (0.0+valuey-self.min)/(self.max-self.min)*self.height+self.y-0.5*self.height)
