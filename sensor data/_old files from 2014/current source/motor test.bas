type button
	dim as string label
	dim as integer y,sizex,sizey,x
	dim as any ptr rawimage,hoveringimage,clickingimage
	dim as byte lastisclicking
	declare sub drawit()
	declare constructor (x as integer,y as integer,sizex as integer,sizey as integer,rawimage as any ptr,hovering as any ptr=0,clickingimage as any ptr=0)
	declare function isclicking() as byte
	declare function ishovering() as byte
    declare function clickedge() as byte
    declare function clickstart() as byte
    declare function clickend() as byte
end type

constructor button(x as integer,y as integer,sizex as integer,sizey as integer,rawimage as any ptr,hoveringimage as any ptr=0,clickingimage as any ptr=0)
	this.x=x
	this.y=y
	this.sizex=sizex
	this.sizey=sizey
	this.rawimage=imagecreate(sizex,sizey)
	this.hoveringimage=imagecreate(sizex,sizey)
	this.clickingimage=imagecreate(sizex,sizey)
	put this.rawimage,(0,0),rawimage,pset
	if not hoveringimage=0 then put this.hoveringimage,(0,0),hoveringimage,pset else put this.hoveringimage,(0,0),rawimage,pset
	if not clickingimage=0 then put this.clickingimage,(0,0),clickingimage,pset else put this.clickingimage,(0,0),rawimage,pset
end constructor

sub button.drawit()
	if isclicking() then
		put (x-1,y-1),clickingimage,pset
	elseif ishovering() then
		put (x,y),hoveringimage,pset
	else
		put (x,y),rawimage,pset
	end if
end sub

function button.isclicking as byte
	dim as integer x,y,buttons 
	getmouse(x,y,,buttons)
	return (buttons and x > this.x and y > this.y and x < this.x+this.sizex and y < this.y+this.sizey) 
end function

function button.ishovering as byte
	dim as integer x,y
	getmouse(x,y)
	return (x > this.x and y > this.y and x < this.x+this.sizex and y < this.y+this.sizey) 
end function

function button.clickedge as byte
    dim as integer tmp=0
    if not lastisclicking and this.isclicking() then tmp = 1
    if lastisclicking and not this.isclicking() then tmp = -1
    lastisclicking=this.isclicking
    return tmp
end function

function button.clickstart as byte
    return this.clickedge=1
end function

function button.clickend as byte
    return this.clickedge=-1
end function




function maxim (a as integer, b as integer) as integer
    if a >  b then return a else return b
end function

declare sub drawStrex (des as any ptr=screenptr, x as integer, y as integer,text as String, style as string="right",col as integer = &hffffff)

type slider
    dim as string lable
    dim as single min,max
    dim as single value
    dim as any ptr wiper,bar
    dim as integer showscale=1
    dim as byte isdragging
    dim as integer x,y,barsizex=-1,barsizey,wipsizex=-1,wipsizey
    declare sub setvalue(value as single)
    declare sub drawit
    declare constructor (x as integer, y as integer, barsizex as integer, barsizey  as integer,max as single, min as single)
    declare sub setwiper(wiper as any ptr,sizex as integer, sizey as integer)
    declare sub setbar(bar as any ptr,sizex as integer, sizey as integer)
    declare function getvalue() as single
end type

constructor slider (x as integer, y as integer, barsizex as integer, barsizey  as integer,max as single, min as single)
     this.x=x
     this.y=y
     this.barsizex=barsizex
     this.barsizey=barsizey
     this.min=min
     this.max=max
     this.bar=imagecreate(barsizex,barsizey)
end constructor

sub slider.setvalue(value as single)
    this.value=value
end sub

sub slider.drawit
    if barsizex<>-1 then
            line bar,(barsizex*0.5-2,0)-(barsizex*0.5,barsizey-1),&h555555,b
            line bar,(0,0)-(barsizex-1,barsizey-1),,b
    end if
    
    if showscale then
        dim as single tmp =(barsizey - barsizey mod 40)/40
        for i as integer = 0 to tmp
            drawstrex bar,barsizex*0.5,(barsizey-12)*i/tmp+2,str((max-min)*i/tmp+min),"middle"
        next i
    end if
    put (x,y),bar,trans
    
    if wipsizex=-1 then
        wipsizex=20
        wipsizey=10
        this.wiper=imagecreate(wipsizex,wipsizey)
        line wiper,(0,0)-(20-1,10-1),&heeeeee,BF
        line wiper,(0,0)-(20-1,10-1),&h000000
        line wiper,(20-1,0)-(0,10-1),&h000000
    end if
    put (x+barsizex*0.5-0.5*wipsizex,y+barsizey-(this.getvalue-max)/(min-max)*barsizey-0.5*wipsizey),wiper,trans
    
end sub

sub drawStrex (des as any ptr=screenptr, x as integer, y as integer,text as String, style as string="left",col as integer=&hffffff)
    select case style
    case "left"
        draw string des,(x,y),text,col
    case "right"
        draw string des,(x-len(text)*8,y),text,col
    case "middle"
        draw string des,(x-len(text)*4,y-5),text,col
    end select
end sub


sub slider.setwiper(wiper as any ptr,sizex as integer, sizey as integer)
    this.wiper=wiper
    this.wipsizex=wipsizex
    this.wipsizey=wipsizey
end sub

sub slider.setbar(bar as any ptr,sizex as integer, sizey as integer)
    this.bar=bar
    this.barsizex=barsizex
    this.barsizey=barsizey
end sub

function slider.getvalue as single
    dim as integer cx,cy,buttons
    getmouse (cx,cy,,buttons)
    
    if buttons=0 then isdragging=0
    if buttons then
        if abs(cx-x-barsizex*0.5)<0.5*barsizex and abs(cy-y-barsizey*0.5)<0.5*barsizey then
            isdragging=1
        end if
    end if
    if isdragging then value=(+y+barsizey-cy)*(min-max)/barsizey+max
    if value<max then value=max
    if value>min then value=min
    return value
end function


type checkbox
	dim as integer y,sizex,sizey,x
	dim as any ptr checkedimage,uncheckedimage,clickingimage
    dim as byte state,isclicking
    dim as string typ
	declare sub drawit()
	declare constructor(x as integer,y as integer,sizex as integer,sizey as integer,checkedimage as any ptr,uncheckedimage as any ptr,typ as String="undef")
	declare function getState() as byte
'	declare function ishovering() as byte
'    declare function clickedge() as byte
'    declare function clickstart() as byte
'    declare function clickend() as byte
end type

constructor checkbox(x as integer,y as integer,sizex as integer,sizey as integer,checkedimage as any ptr,uncheckedimage as any ptr,typ as String="undef")
	this.x=x
	this.y=y
	this.sizex=sizex
	this.sizey=sizey
	this.checkedimage=imagecreate(sizex,sizey)
    put this.checkedimage,(0,0),checkedimage,pset
	this.uncheckedimage=imagecreate(sizex,sizey)
    put this.uncheckedimage,(0,0),uncheckedimage,pset
    this.typ="circle"
    if typ="box" then this.typ="box"
end constructor

sub checkbox.drawit()
	if getstate() then
		put (x,y),checkedimage,trans
	else
		put (x,y),uncheckedimage,trans
	end if
end sub

function checkbox.getstate as byte
	dim as integer x,y,buttons 
	getmouse(x,y,,buttons)
	if buttons then
        if  (typ="circle" and (x-this.x-sizex/2)^2/(sizex/2)^2 + (y-this.y-sizey/2)^2/(sizey/2)^2 <= 1) or _
            (typ="box"    and abs(x-this.x-sizex/2)<sizex/2 and abs(y-this.y-sizey/2)<sizey/2) then
            isclicking=1
        end if
    end if
    if isclicking and buttons=0 then
        isclicking=0
        state xor=1
    end if
    return state
end function



#inclib "I2C" 'provide functions for reading/writing sensor data via I²C:
#inclib "wiringPi"
' sensor addresses:
' &h6d --> gyrometer L3GD60H
' &h1d --> accelerometer/magnetometer LSM303D
' &h5d --> Barometer

declare sub write_I2C cdecl alias "write_I2C" (address as unsigned byte, reg as unsigned byte, value as unsigned byte )

declare function read_I2C cdecl alias "read_I2C" (address as unsigned byte, reg as unsigned byte) as unsigned byte


#include once "includes/PWMApi.bas"

screenres 800,600,32

dim as integer allonoffx=60,allonoffy=40
dim as any ptr allonoffimg(0 to 3)
allonoffimg(0)=imagecreate(allonoffx,allonoffy)
line allonoffimg(0),(0,0)-(allonoffx-1,allonoffy-1),&h00cc00,bf
line allonoffimg(0),(0,0)-(allonoffx-1,allonoffy-1),&hffffff,b
Drawstrex allonoffimg(0),allonoffx/2,allonoffy/2,"all on","middle"
allonoffimg(1)=imagecreate(allonoffx,allonoffy)
line allonoffimg(1),(0,0)-(allonoffx-1,allonoffy-1),&h009900,bf
line allonoffimg(1),(0,0)-(allonoffx-1,allonoffy-1),&hffffff,b
Drawstrex allonoffimg(1),allonoffx/2,allonoffy/2,"all on","middle"
allonoffimg(2)=imagecreate(allonoffx,allonoffy)
line allonoffimg(2),(0,0)-(allonoffx-1,allonoffy-1),&hcc0000,bf
line allonoffimg(2),(0,0)-(allonoffx-1,allonoffy-1),&hffffff,b
Drawstrex allonoffimg(2),allonoffx/2,allonoffy/2,"all off","middle"
allonoffimg(3)=imagecreate(allonoffx,allonoffy)
line allonoffimg(3),(0,0)-(allonoffx-1,allonoffy-1),&h990000,bf
line allonoffimg(3),(0,0)-(allonoffx-1,allonoffy-1),&hffffff,b
Drawstrex allonoffimg(3),allonoffx/2,allonoffy/2,"all off","middle"

dim as button ptr button1=new button(230,280,allonoffx,allonoffy,allonoffimg(0),allonoffimg(1))

dim as slider ptr sliders(5)
dim as checkbox ptr  checkboxes(5)

for i as integer = 0 to 5
    sliders(i)=new slider(230+200*cos(6.283/6*i),200+200*sin(6.283/6*i),28,200,0,100)
    dim as any ptr tmp1=imagecreate(60,60)
    dim as any ptr tmp2=imagecreate(60,60)
    circle tmp1,(30,30),29,&hffffff
    circle tmp2,(30,30),29,&h333333
    drawstrex tmp1,31,31,str(i+1),"middle",&hffffff
    drawstrex tmp2,31,31,str(i+1),"middle",&h333333
    checkboxes(i)=new checkbox(263+200*cos(6.283/6*i),274+200*sin(6.283/6*i),60,60,tmp1,tmp2,"circle")

next i

dim as slider ptr all = new slider(600,100,40,400,0,100)
dim as single lastallvalue

initPWM()
do
    screenlock
        cls
        button1->drawit
        for i as integer = 0 to 5
            sliders(i)->drawit
            checkboxes(i)->drawit
        next i
        all->drawit
            
    locate 1,1
    for i as integer = 0 to 5
        print "motor "+str(i+1)+": "+str(sliders(i)->value*checkboxes(i)->state)+"%"
    next i
    
    screenunlock
    
    if button1->clickend then
        if button1->rawimage=allonoffimg(2) then
            button1->rawimage=allonoffimg(0)
            button1->hoveringimage=allonoffimg(1)
            button1->clickingimage=allonoffimg(1)
            for i as integer = 0 to 5
                checkboxes(i)->state=0
            next i
        else
            button1->rawimage=allonoffimg(2)
            button1->hoveringimage=allonoffimg(3)
            button1->clickingimage=allonoffimg(2)
            for i as integer = 0 to 5
                checkboxes(i)->state=1
            next i
        end if
    end if
    
    for i as integer = 0 to 5
        sliders(i)->setvalue(sliders(i)->value+(-lastallvalue+all->value))
    next i
    lastallvalue=all->value
    
    for i as integer = 0 to 5
        setpwm(i,0,sliders(i)->value*checkboxes(i)->state/100*(2^12-1))
    next i
	sleep 10
loop while inkey=""
