
type motorspeeds
	dim as single firs=0
	dim as single seco=0
	dim as single thir=0
	dim as single fort=0
	dim as single fivt=0
	dim as single sixt=0
end type

DIM shared AS BYTE stayZ =0, stayXY=0 'booleans

function PID(_
			QuadcopterX    AS DOUBLE=1/3, QuadcopterY     AS DOUBLE=1/3, QuadcopterZ   AS DOUBLE=1/3,_'position
			QuadcopterRoll AS DOUBLE=1/3, QuadcopterPitch AS DOUBLE=1/3, QuadcopterYaw AS DOUBLE=1/3,_'rotation in °
			XUserInput     AS DOUBLE=0  , YUserInput      AS DOUBLE=0  , ZUserInput    AS DOUBLE=0,powUserInput    AS DOUBLE=0 )  _'input: -1 to 1
			as motorspeeds
    dim as motorspeeds m
   
	CONST      AS DOUBLE  rotKp=300, rotKi=0, rotKd=60
	CONST      AS DOUBLE  posKp=300, posKi=0, posKd=40
	STATIC AS DOUBLE  targetRoll =0 , rollError =0, rollPreviousError =0, rollIntegral =0, rollDerivative =0, rollOutput =0
	STATIC AS DOUBLE  targetPitch=0 , pitchError=0, pitchPreviousError=0, pitchIntegral=0, pitchDerivative=0, pitchOutput=0
	STATIC AS DOUBLE  targetyaw  =0 , yawError  =0, yawPreviousError  =0, yawIntegral  =0, yawDerivative  =0, yawOutput  =0
	STATIC AS DOUBLE  targetX    =0 , xError    =0, xPreviousError    =0, xIntegral    =0, xDerivative    =0, xOutput    =0
	STATIC AS DOUBLE  targetY    =0 , yError    =0, yPreviousError    =0, yIntegral    =0, yDerivative    =0, yOutput    =0
	STATIC AS DOUBLE  targetZ    =20, zError    =0, zPreviousError    =0, zIntegral    =0, zDerivative    =0, zOutput    =0

	'STATIC AS SINGLE coeff(6,6)= {{ 0,    1,  2/3, 0, 0, 0},_
	'						      { 1,  0.5, -2/3, 0, 0, 0},_
	'						      { 1, -0.5,  2/3, 0, 0, 0},_
	'						      { 0,   -1, -2/3, 0, 0, 0},_
	'						      {-1, -0.5,  2/3, 0, 0, 0},_
	'						      {-1,  0.5, -2/3, 0, 0, 0}}
	STATIC AS SINGLE coeff(6,6)= {{  1,    0, -1, 0, 0, 0},_
							      {  0,    1,  1, 0, 0, 0},_
							      { -1,    0, -1, 0, 0, 0},_
							      {  0,   -1,  1, 0, 0, 0},_
							      {  0,    0,   , 0, 0, 0},_
							      {  0,    0,   , 0, 0, 0}}
    IF QuadcopterPitch=1/3 THEN QuadcopterPitch=targetPitch
    IF QuadcopterRoll =1/3 THEN QuadcopterRoll=targetRoll
    IF QuadcopterYaw  =1/3 THEN QuadcopterYaw =targetYaw
    IF QuadcopterX    =1/3 THEN QuadcopterX=targetX
    IF QuadcopterY    =1/3 THEN QuadcopterY=targetY
    IF QuadcopterZ    =1/3 THEN QuadcopterZ=targetZ
    'IF LBOUND(funcoutput)>0 OR LBOUND(funcoutput)<3 THEN PRINT"ERROR in func PID: array too small or out of bounds" : EXIT SUB
    
    rollError = (targetRoll - QuadcopterRoll)/360 'normalize: 360° error => 1
    rollIntegral = rollIntegral + rollError*0.0001 '--------------\
    rollDerivative = (rollError - rollPreviousError)*0.0001 'make it relative to the average deltaT in seconds
    '***debug***
    'print(rotKp*rollError & " " & rotKd*rollDerivative & " " & rollOutput & " " & rollPreviousError & "  " & targetRoll)
    'print(rollOutput & "  " & pitchOutput & "  " & yawOutput & "  " & xOutput & "  " & yOutput & "  " & zOutput)
    '***debug***
    rollOutput = (rotKp*rollError + rotKi*rollIntegral + rotKd*rollDerivative)
    rollPreviousError = rollError
    
    pitchError = (targetPitch - QuadcopterPitch)/360
    pitchIntegral = pitchIntegral + pitchError*0.0001
    pitchDerivative = (pitchError - pitchPreviousError)*0.0001
    pitchOutput = (rotKp*pitchError + rotKi*pitchIntegral + rotKd*pitchDerivative)
    pitchPreviousError = pitchError
    
    yawError = (targetyaw - QuadcopterYaw)/360
    yawIntegral = yawIntegral + yawError*0.0001
    yawDerivative = (yawError - yawPreviousError)*0.0001
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

    targetPitch=6*YUserInput
    targetRoll=6*XUserInput
    targetYaw=6*ZUserInput
    IF NOT stayZ THEN targetZ=QuadcopterZ
    
    dim as integer outputs(6)={0,0,0,0,0,0}
    
    locate 1,1
    for i as integer = 0 to 5
		outputs(i)=50 + coeff(i,0)*rollOutput + coeff(i,1)*pitchOutput + coeff(i,2)*yawoutput +  (coeff(i,3)*xOutput + coeff(i,4)*yOutput)*stayXY + coeff(i,5)*zOutput
		outputs(i)*=powuserinput
		print ""
		if outputs(i)<0   then outputs(i)=0
		if outputs(i)>100 then outputs(i)=100
    next i
    
	m.firs=outputs(0)
	m.seco=outputs(1)
	m.thir=outputs(2)
	m.fort=outputs(3)
	m.fivt=outputs(4)
	m.sixt=outputs(5)
	
	return m
END function

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
