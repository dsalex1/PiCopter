#include once "TSNE_V3.bi"                          'Die TCP Netzwerkbibliotek integrieren
dim shared as uinteger G_Server
'##############################################################################################################
'   Deklarationen für die Empfänger Sub Routinen erstellen
Declare Sub TSNE_Disconnected           (ByVal V_TSNEID as UInteger)
Declare Sub TSNE_Connected              (ByVal V_TSNEID as UInteger)
Declare Sub TSNE_NewData                (ByVal V_TSNEID as UInteger, ByRef V_Data as String)
Declare Sub TSNE_NewConnection          (ByVal V_TSNEID as UInteger, ByVal V_RequestID as Socket, ByVal V_IPA as String)
Declare Sub TSNE_NewConnectionCanceled  (ByVal V_TSNEID as UInteger, ByVal V_IPA as String)

type userInput
    dim roll as single
    dim pitch as single
    dim yaw as single
    dim power as single
end type

dim shared as userInput recievedUserInput
dim shared as single inputx1,inputy1,inputx2,inputy2
'##############################################################################################################                      'Signalisieren das wir den Server jetzt inizialisieren

declare sub initControls
declare function getuserinput as userinput

sub initControls
    TSNE_Create_Server(G_Server, 1234, 10, @TSNE_NewConnection, @TSNE_NewConnectionCanceled)   'Server erstellen
end sub

'##############################################################################################################
Sub TSNE_Disconnected(ByVal V_TSNEID as UInteger)   'Empfänger für das Disconnect Signal (Verbindung beendet)
End Sub

Sub TSNE_Connected(ByVal V_TSNEID as UInteger)      'Empfänger für das Connect Signal (Verbindung besteht)
End Sub

'##############################################################################################################
Sub TSNE_NewConnection(ByVal V_TSNEID as UInteger, ByVal V_RequestID as Socket, ByVal V_IPA as String)      'Empfänger für das NewConnection Signal (Neue Verbindung)                              'Erhält von er Accept die IP-Adresse dieses Servers, so wie der Client sie sieht.
    DIM TNewTSNEID AS UINTEGER                          'Eine Variable welche die Neue TSNEID beinhaltet
    DIM TReturnIPA AS STRING 
    TSNE_Create_Accept(V_RequestID, TNewTSNEID, TReturnIPA, @TSNE_Disconnected, @TSNE_Connected, @TSNE_NewData)
End Sub

'##############################################################################################################
Sub TSNE_NewConnectionCanceled(ByVal V_TSNEID as UInteger, ByVal V_IPA as String)
End Sub


'##############################################################################################################
Sub TSNE_NewData(ByVal V_TSNEID as UInteger, ByRef V_Data as String)    'Empfänger für neue Daten
'Als beispiel habe ich einen HTTP-Server gewählt. Darum werden wir jetzt nach eienm HTTP-Header suchen
Dim XPos as UInteger = InStr(1, V_Data, Chr(13, 10, 13, 10))     'Wir suchen nach dem Ende des Headers (2x zeilenumbruch)
Dim XHeader as String = Mid(V_Data, 1, XPos - 1)     'Wir haben ihn gefunden und schneiden Ihn von den Daten ab.
V_Data = Mid(V_Data, XPos + 4) 
'Die Daten selbst (falls vorhanden) brauchen keinen Header. Darum schneiden wir diesen header ab.

xpos=InStr(1, V_Data,"x1=")
recievedUserInput.yaw=val(mid(V_Data,xpos+3,InStr(xpos, V_Data,"&")-xpos-3))
xpos=InStr(1, V_Data,"y1=")
recievedUserInput.power=val(mid(V_Data,xpos+3,InStr(xpos, V_Data,"&")-xpos-3))
xpos=InStr(1, V_Data,"x2=")
recievedUserInput.roll=val(mid(V_Data,xpos+3,InStr(xpos, V_Data,"&")-xpos-3))
xpos=InStr(1, V_Data,"y2=")
recievedUserInput.pitch=val(mid(V_Data,xpos+3,InStr(xpos, V_Data,"&")-xpos-3))
TSNE_Disconnect(V_TSNEID)                           'Am ende beenden wir die Verbindung, da alles nötig übertragen wurde. Und keine weitere aktion nötig ist.
END SUB

function getUserInput() as userinput
    return recievedUserInput
end function

