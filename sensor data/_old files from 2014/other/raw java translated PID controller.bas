declare SUB PID(funcouput() AS INTEGER,_
                QuadcopterX     AS DOUBLE=1/3, QuadcopterY    AS DOUBLE=1/3, QuadcopterZ   AS DOUBLE=1/3,_'position
                QuadcopterPitch AS DOUBLE=1/3, QuadcopterRoll AS DOUBLE=1/3, QuadcopterYaw AS DOUBLE=1/3,_'rotation in °
                XUserInput      AS DOUBLE=0  , YUserInput     AS DOUBLE=0  , ZUserInput    AS DOUBLE=0)  _'input: -1 to 1
    

DIM SHARED AS BYTE    stayZ =0, stayXY 'boolean
DIM SHARED AS DOUBLE  XUserInput=0, YUserInput=0, ZUserInput=0
CONST      AS DOUBLE  rotKp=30, rotKi=0, rotKd=6
CONST      AS DOUBLE  posKp=30, posKi=0, posKd=4
DIM SHARED AS DOUBLE  targetRoll =0 , rollError =0, rollPreviousError =0, rollIntegral =0, rollDerivative =0, rollOutput =0
DIM SHARED AS DOUBLE  targetPitch=0 , pitchError=0, pitchPreviousError=0, pitchIntegral=0, pitchDerivative=0, pitchOutput=0
DIM SHARED AS DOUBLE  targetyaw  =0 , yawError  =0, yawPreviousError  =0, yawIntegral  =0, yawDerivative  =0, yawOutput  =0
DIM SHARED AS DOUBLE  targetX    =0 , xError    =0, xPreviousError    =0, xIntegral    =0, xDerivative    =0, xOutput    =0
DIM SHARED AS DOUBLE  targetY    =0 , yError    =0, yPreviousError    =0, yIntegral    =0, yDerivative    =0, yOutput    =0
DIM SHARED AS DOUBLE  targetZ    =20, zError    =0, zPreviousError    =0, zIntegral    =0, zDerivative    =0, zOutput    =0
DIM SHARED AS INTEGER funcoutput(0 TO 3) = {0,0,0,0}
SUB PID(funcouput() AS INTEGER,_
    QuadcopterX     AS DOUBLE=1/3, QuadcopterY    AS DOUBLE=1/3, QuadcopterZ   AS DOUBLE=1/3,_'position
    QuadcopterPitch AS DOUBLE=1/3, QuadcopterRoll AS DOUBLE=1/3, QuadcopterYaw AS DOUBLE=1/3,_'rotation in °
    XUserInput      AS DOUBLE=0  , YUserInput     AS DOUBLE=0  , ZUserInput    AS DOUBLE=0)  _'input: -1 to 1
    
    IF QuadcopterPitch=1/3 THEN QuadcopterX=targetPitch
    IF QuadcopterRoll =1/3 THEN QuadcopterX=targetRoll
    IF QuadcopterYaw  =1/3 THEN QuadcopterX=targetYaw
    IF QuadcopterX    =1/3 THEN QuadcopterX=targetX
    IF QuadcopterY    =1/3 THEN QuadcopterX=targetY
    IF QuadcopterZ    =1/3 THEN QuadcopterX=targetZ
    IF LBOUND(funcouput)>0 OR LBOUND(funcouput)<4 THEN PRINT"ERROR in func PID: array too small or out of bounds" : EXIT SUB
    
    rollError = (targetRoll - QuadcopterRoll)/360 'normalize: 360° error => 1
    rollIntegral = rollIntegral + rollError*0.0001 '--------------\
    rollDerivative = (rollError - rollPreviousError)/0.0001 'make it relative to the average deltaT in seconds
    rollOutput = (rotKp*rollError + rotKi*rollIntegral + rotKd*rollDerivative)
    rollPreviousError = rollError
    
    pitchError = (targetPitch - QuadcopterPitch)/360
    pitchIntegral = pitchIntegral + pitchError*0.0001
    pitchDerivative = (pitchError - pitchPreviousError)/0.0001
    pitchOutput = (rotKp*pitchError + rotKi*pitchIntegral + rotKd*pitchDerivative)
    pitchPreviousError = pitchError
    
    yawError = (targetyaw - QuadcopterYaw)/360
    yawIntegral = yawIntegral + yawError*0.0001
    yawDerivative = (yawError - yawPreviousError)/0.0001
    yawOutput = (rotKp*yawError + rotKi*yawIntegral + rotKd*yawDerivative)
    yawPreviousError = yawError
    
    xError = (targetX - QuadcopterX)/1000 'normalize...
    xIntegral = xIntegral + xError/0.0001
    xDerivative = (xError - xPreviousError)/0.0001
    xOutput = (posKp*xError + posKi*xIntegral + posKd*xDerivative)
    xPreviousError = xError
    
    yError = (targetY - QuadcopterY)/1000
    yIntegral = yIntegral + yError/0.0001
    yDerivative = (yError - yPreviousError)/0.0001
    yOutput = (posKp*yError + posKi*yIntegral + posKd*yDerivative)
    yPreviousError = yError
    
    zError = ((targetZ+40*ZUserInput+0) - QuadcopterZ)/1000
    zIntegral = zIntegral + zError/0.0001
    zDerivative = (zError - zPreviousError)/0.0001
    zOutput = (posKp*zError + posKi*zIntegral + posKd*zDerivative)
    zPreviousError = zError
    '***debug***
    'print(posKp*zError & " " & posKd*zDerivative & " " & zOutput & " " & QuadcopterZ & "  " & targetZ)
    'print(rollOutput & "  " & pitchOutput & "  " & yawOutput & "  " & xOutput & "  " & yOutput & "  " & zOutput & "  " & staypos)
    'print(QuadcopterZ & "   " & zOutput & "   " & ZAccel & "   " & ZVelo & "  " & QuadcopterRoll & "  " & QuadcopterPitch)
    '***debug***
    targetPitch=6*XUserInput
    targetRoll=6*YUserInput
    IF NOT stayZ THEN targetZ=QuadcopterZ
    
    funcoutput(0) = INT(50+  rollOutput +  pitchOutput +  yawOutput + (-xOutput+ yOutput)*stayXY +3*zOutput)
    funcoutput(1) = INT(50+ -rollOutput +  pitchOutput + -yawOutput + (-xOutput+-yOutput)*stayXY +3*zOutput)
    funcoutput(2) = INT(50+  rollOutput + -pitchOutput + -yawOutput + ( xOutput+ yOutput)*stayXY +3*zOutput)
    funcoutput(3) = INT(50+ -rollOutput + -pitchOutput +  yawOutput + ( xOutput+-yOutput)*stayXY +3*zOutput)
END SUB

'DIM Sub Staypos(value As Boolean, QuadcopterX As Double, QuadcopterY As Double, QuadcopterZ As Double) 
'    StayXY(value, QuadcopterX, QuadcopterY)
'    StayZ(value, QuadcopterZ)
'    Return
'End Sub
'DIM Sub StayXY(value As Boolean, QuadcopterX As Double, QuadcopterY As Double)
'    If value=True Then
'        targetX=QuadcopterX
'        targetY=QuadcopterY
'        stayXY=True
'    ElseIf value=False Then
'        stayXY=False
'    End If
'    Return
'End Sub
'DIM Sub StayZ(value As Boolean, QuadcopterZ As Double)
'    If value=True Then
'        targetZ=QuadcopterZ
'        stayZ=True
'    ElseIf value=False Then
'        stayZ=False
'    End If
'    Return
'End Sub