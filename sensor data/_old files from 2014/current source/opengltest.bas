

#INCLUDE "fbgfx.bi"
#INCLUDE ONCE "GL/gl.bi"
#INCLUDE ONCE "GL/glu.bi"

declare sub glinit
declare sub rendercube(x as single,y as single,z as single,rotx as single,roty as single,rotz as single,sizex as single,sizey as single,sizez as single)
declare sub renderarrow(x as single,y as single,z as single,rotx as single,roty as single,rotz as single,length as single, col as integer)
    
'-------------------------
SCREENres 800, 600, , 2

glinit()
dim as single XRichtg,YRichtg,ZRichtg
dim as string _
Tlinks       = CHR(255) & CHR( 75),  _' beim Drücken der Taste CursorLinks gibt die Tastatur CHR(255) & CHR( 75) zurück
Trechts      = CHR(255) & CHR( 77),  _' CursorRechts
Tvor         = CHR(255) & CHR( 72),  _' CursorHoch
Tzurueck     = CHR(255) & CHR( 80),  _' CursorRunter
TCtrlVor     = CHR(255) & CHR(141),  _'Ctrl oder STRG zusammen mit CursorHoch
TCtrlZurueck = CHR(255) & CHR(145)'Ctrl oder STRG zusammen mit CursorRunter

DO UNTIL inkey = CHR(27) :'die Schleife solange immer wiederholen, bis in der Variablen Tastendruck die Esc-Taste (chr(27) steht
	locate 1,1
	print rnd
   glClear GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT  :'bisherig erstellte Objekte löschen, unsere 3D-Welt wieder von Neuem an erstellen
                                       :'aktuelle Position sichern (2.Zettel mit gleicher Pos auf PositionsSTACK)
   '---------------------------
   'ProgrammSchleife
   '---------------------------

   'JE NACH TASTENDRUCK DEN ENTSPRECHENDEN POSITIONSWERT VERÄNDERN
   if MULTIKEY(&h48) then XRichtg += +0.5 :'um -0.01 in X-Richtung = 0.01 nach links
   if MULTIKEY(&h50) then XRichtg += -0.5   :'um +0.01 in X-Richtung = 0.01 nach links
   if MULTIKEY(&h4d) then YRichtg += +0.5 :'um +0.01 in Y-Richtung = 0.01 nach oben
   if MULTIKEY(&h4b) then YRichtg += -0.5 :'um -0.01 in Y-Richtung = 0.01 nach unten

    glPushMatrix 
    
    rendercube(0,-1,-10,XRichtg,YRichtg,0,2,1,6)
    renderarrow(0,-1,-10,XRichtg,YRichtg,0,2,&hff0000)
    renderarrow(0,-1,-10,XRichtg,YRichtg+180,90,2,&h00ff00)
    renderarrow(0,-1,-10,XRichtg,YRichtg+90,90,2,&h0000ff)

    
    glPopMatrix 
   FLIP                  'liebes OpenGL, zeig alles, was in der Schleife für dich vornedran steht, auf Monitor an
LOOP
END

sub renderarrow(x as single,y as single,z as single,rotx as single,roty as single,rotz as single,lenght as single,col as integer)
    glPushMatrix
    glTranslatef x,y,z
    glrotatef rotx, 1, 0, 0    :'<----------- um X-Achse drehen
    glrotatef roty, 0, 1, 0    :'<----------- um Y-Achse drehen
    glrotatef rotz, 0, 0, 1
    
    glbegin gl_lines
        glColor3f col shr 16 and &hff,col shr 8 and &hff,col shr 0 and &hff      :' Zeichenfarbe auf gelb
        glVertex3f 0,-lenght,0
        glVertex3f 0,lenght,0
        
        for i as integer = 1 to 30 
            glVertex3f 0,lenght,0
            glVertex3f 0.1*sin(i/30*6.283),lenght-0.2,0.1*cos(i/30*6.283)
        next i 
    glend
    glpopmatrix
end sub

sub rendercube(x as single,y as single,z as single,rotx as single,roty as single,rotz as single,sizex as single,sizey as single,sizez as single)
    glPushMatrix 
    glTranslatef x,y,z
    glrotatef rotx, 1, 0, 0    :'<----------- um X-Achse drehen
    glrotatef roty, 0, 1, 0    :'<----------- um Y-Achse drehen
    glrotatef rotz, 0, 0, 1 
    glBegin gl_quads
       glColor4f 1.0,1.0,0.0,1 :' Zeichenfarbe auf gelb
       glVertex3f  -sizex/2, +sizey/2, +sizey/2  :' vorne oben links
       glVertex3f  +sizex/2, +sizey/2, +sizey/2  :' vorne oben rechts
       glVertex3f  +sizex/2, -sizey/2, +sizey/2  :' vorne unten rechts
       glVertex3f  -sizex/2, -sizey/2, +sizey/2  :' vorne unten links
       
       glVertex3f  -sizex/2, +sizey/2, +sizey/2  :' vorne oben links
       glVertex3f  +sizex/2, +sizey/2, +sizey/2  :' vorne oben rechts
       glVertex3f  +sizex/2, +sizey/2, -sizey/2  :' hinten oben rechts
       glVertex3f  -sizex/2, +sizey/2, -sizey/2  :' hinten oben links
       
       glVertex3f  +sizex/2, +sizey/2, +sizey/2  :' vorne oben rechts
       glVertex3f  +sizex/2, +sizey/2, -sizey/2  :' hinten oben rechts
       glVertex3f  +sizex/2, -sizey/2, -sizey/2  :' hinten unten rechts
       glVertex3f  +sizex/2, -sizey/2, +sizey/2  :' vorne unten rechts
              
       glVertex3f  -sizex/2, +sizey/2, +sizey/2  :' vorne oben links
       glVertex3f  -sizex/2, -sizey/2, +sizey/2  :' vorne unten links
       glVertex3f  -sizex/2, -sizey/2, -sizey/2  :' hinten unten links
       glVertex3f  -sizex/2, +sizey/2, -sizey/2  :' hinten oben links

       
       glVertex3f  -sizex/2, -sizey/2, +sizey/2  :' vorne unten links
       glVertex3f  +sizex/2, -sizey/2, +sizey/2  :' vorne unten rechts
       glVertex3f  +sizex/2, -sizey/2, -sizey/2  :' hinten unten rechts
       glVertex3f  -sizex/2, -sizey/2, -sizey/2  :' hinten unten links
       
       glVertex3f  -sizex/2, +sizey/2, -sizey/2  :' hinten oben links
       glVertex3f  +sizex/2, +sizey/2, -sizey/2  :' hinten oben rechts
       glVertex3f  +sizex/2, -sizey/2, -sizey/2  :' hinten unten rechts
       glVertex3f  -sizex/2, -sizey/2, -sizey/2  :' hinten unten links
    glEnd
    
    glBegin gl_lines
       glColor3f 0.0,0.0,0.0      :' Zeichenfarbe auf gelb
       
       dim as single wfs=0.015
       glVertex3f  -sizex/2-wfs, +sizey/2+wfs, +sizey/2+wfs  :' vorne oben links
       glVertex3f  +sizex/2+wfs, +sizey/2+wfs, +sizey/2+wfs  :' vorne oben rechts
       
       glVertex3f  +sizex/2+wfs, -sizey/2-wfs, +sizey/2+wfs  :' vorne unten rechts
       glVertex3f  -sizex/2-wfs, -sizey/2-wfs, +sizey/2+wfs  :' vorne unten links
       
       glVertex3f  -sizex/2-wfs, +sizey/2+wfs, +sizey/2+wfs  :' vorne oben links
       glVertex3f  -sizex/2-wfs, -sizey/2-wfs, +sizey/2+wfs  :' vorne unten links
       
       glVertex3f  +sizex/2+wfs, -sizey/2-wfs, +sizey/2+wfs  :' vorne unten rechts
       glVertex3f  +sizex/2+wfs, +sizey/2+wfs, +sizey/2+wfs  :' vorne oben rechts
       
       glVertex3f  -sizex/2-wfs, +sizey/2+wfs, -sizey/2-wfs  :' hinten oben links
       glVertex3f  +sizex/2+wfs, +sizey/2+wfs, -sizey/2-wfs  :' hinten oben rechts
       
       glVertex3f  +sizex/2+wfs, -sizey/2-wfs, -sizey/2-wfs  :' hinten unten rechts
       glVertex3f  -sizex/2-wfs, -sizey/2-wfs, -sizey/2-wfs  :' hinten unten links
       
       glVertex3f  -sizex/2-wfs, +sizey/2+wfs, -sizey/2-wfs  :' hinten oben links
       glVertex3f  -sizex/2-wfs, -sizey/2-wfs, -sizey/2-wfs  :' hinten unten links
       
       glVertex3f  +sizex/2+wfs, -sizey/2-wfs, -sizey/2-wfs  :' hinten unten rechts
       glVertex3f  +sizex/2+wfs, +sizey/2+wfs, -sizey/2-wfs  :' hinten oben rechts
       
       glVertex3f  +sizex/2+wfs, +sizey/2+wfs, +sizey/2+wfs  :' vorne oben links
       glVertex3f  +sizex/2+wfs, +sizey/2+wfs, -sizey/2-wfs:' hinten oben rechts
       
       glVertex3f  -sizex/2-wfs, -sizey/2-wfs, +sizey/2+wfs  :' vorne unten rechts
       glVertex3f  -sizex/2-wfs, -sizey/2-wfs, -sizey/2-wfs  :' hinten unten links
       
       glVertex3f  -sizex/2-wfs, +sizey/2+wfs, +sizey/2+wfs  :' vorne oben links
       glVertex3f  -sizex/2-wfs, +sizey/2+wfs, -sizey/2-wfs  :' hinten oben links
       
       glVertex3f  +sizex/2+wfs, -sizey/2-wfs, +sizey/2+wfs  :' vorne unten rechts
       glVertex3f  +sizex/2+wfs, -sizey/2-wfs, -sizey/2-wfs  :' hinten unten rechts
    glEnd
    glPopMatrix 
end sub


















sub glinit
    glViewport 0, 0, 800, 600                      ' den Current Viewport auf eine Ausgangsposition setzen
    glMatrixMode GL_PROJECTION                     ' Den Matrix-Modus Projection wählen
    glLoadIdentity                                 ' Diesen Modus auf Anfangswerte setzen
    gluPerspective 45.0, 800.0/600.0, 0.1, 100.0   ' Grundeinstellungen des Anezeigefensters festlegen
    glMatrixMode GL_MODELVIEW                      ' Auf den Matrix-Modus Modelview schalten
    glLoadIdentity                                 ' und auch diesen auf Anfangswerte setzen
    glClearColor 0.5, 0.5, 0.50, 0.0               ' Setze Farbe für löschen auf Mittelgrau
    glClearDepth 1.0                               ' Depth-Buffer Löschen erlauben
    glEnable GL_DEPTH_TEST                         ' den Tiefentest GL_DEPTH_TEST einschalten
    glClear GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT  'Tiefen- und Farbpufferbits löschen
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glEnable (GL_POINT_SMOOTH)' Antialiasing für Punkte einschalten
    glEnable (GL_LINE_SMOOTH)' Antialiasing für Linien einschalten
end sub
