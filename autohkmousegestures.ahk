;**************************************************************************************************
;**                                                                                                                                                                                            **
;**                                                               autohkmousegestures                                                                                         **
;**                                                                                                                                                                                            **
;**                                                                             v2.1                                                                                                        **
;**                                                                                                                                                                                            **
;**************************************************************************************************


;custom gestures start in line 577 (ToDo: make the configuration more accesible)




;**************************************************************************************************
;**                                                                                                                                                                                            **
;**                                                                                system                                                                                                **
;**                                                                                                                                                                                            **
;**************************************************************************************************

#InstallMouseHook
;#InstallKeybdHook
#SingleInstance force ;16/05/09
#HotkeyInterval 4000
#MaxHotkeysPerInterval 200
Coordmode, Mouse, Screen
;BlockInput Mouse        ; user mouse input is ignored during MouseMove
SetMouseDelay -1

detectLong:=false ;detectar la distancia del gesto, no solo la dirección
limitAngle:= 45 ;28 ;grados de detección, en 45 no se identifican diagonales, en 0 no se identifica cardinales ; rango entre 0º-45º  ; 22.5 da la misma prioridad a todas las direcciones
minDistance=50 ;distancia minima para detectar un gesto (aproximadamente)
minStep:=10 ;distancia minima requerida para checkear cambios repentinos de direccion
inactivityTime=450 ;en ms, tiempo maximo de inactividad antes de reiniciar el gesto
execAfterInactivityTime=true ;forzar la accion cancelada por inactividad
waitTime=50 ;en ms tiempo de espera hasta revisar la nueva posicion
MulticlickTime=300 ; time for a quick click : normal click show ?b/?b ,fast click show ?bb , fast click without other button pressed always shows b/b
copyMacro:=false ; copy the unhandled macro to the clipboard 
showGuide:=false ;show tooltip of the unhadled macro
tooltipTime=2000 ; tiempo que se mostrara el tooltip de ayuda
back2default:=true ; en caso que no se encuentre el macro realizar la accion del primer boton presionado
includeVirtual:=true ;incluye clicks en touch screens
DemonScroll:=false

GroupAdd, explorer_group, ahk_class CabinetWClass
GroupAdd, explorer_group, ahk_class ExploreWClass
GroupAdd, explorer_group, ahk_class TMainForm.UnicodeClass ;explorer
GroupAdd, explorer_group, ahk_class IEFrame

GroupAdd, browser_group, ahk_class OpWindow               ; Opera
GroupAdd, browser_group, ahk_class OperaWindowClass
GroupAdd, browser_group, ahk_class MozillaUIWindowClass   ; Firefox
GroupAdd, browser_group, ahk_class Chrome_WidgetWin_0
GroupAdd, browser_group, ahk_class IEFrame


GroupAdd, disabled_group, ahk_class com.alias.TpWin32SketchWindow
GroupAdd, disabled_group, DAZ Studio 3.1 
GroupAdd, disabled_group, DOSBox 
GroupAdd, disabled_group, Manga MeeYaaCE v2.4Beta
GroupAdd, disabled_group, ahk_class VirtualConsoleClass

use_mbutton=false
gosub initialize

return
; /**************************************************************************************************/

~#esc::suspend

;+#d --> debug
^+#m:: 
{
	ToolTip reloading mouse gestures
	sleep 750	
	reload
return
}
^+#p:: ;disable temporaly
{
	if ( paused )
	{
		showTooltip("resuming")
		paused:=False		
		;hotkey $lbutton,on 	;disable control over lbutton; necesary to enable drag&drop
		hotkey $rbutton,on      ; list whatever mouse buttons you want tracked.
		if(use_mbuton) hotkey $mbutton,on      ; works best if all available listed
		hotkey $xbutton1,on         ; lbutton only tracked when other mouse buttons start tracking
		hotkey $xbutton2,on
		
		;hotkey $lbutton up,on 	;disable control over lbutton; necesary to enable drag&drop	
		hotkey $rbutton up,on      ; list whatever mouse buttons you want tracked.
		if(use_mbuton) hotkey $mbutton up,on      ; works best if all available listed
		hotkey $xbutton1 up,on         ; lbutton only tracked when other mouse buttons start tracking
		hotkey $xbutton2 up,on

		hotkey $WheelUp,on
		hotkey $WheelDown,on		
	} else {
		showTooltip("paused")
		paused:=True
		;hotkey $lbutton,off 	;disable control over lbutton; necesary to enable drag&drop
		hotkey $rbutton,off      ; list whatever mouse buttons you want tracked.
		if(use_mbuton) hotkey $mbutton,off      ; works best if all available listed
		hotkey $xbutton1,off         ; lbutton only tracked when other mouse buttons start tracking
		hotkey $xbutton2,off
		
		;hotkey $lbutton up,off 	;disable control over lbutton; necesary to enable drag&drop	
		hotkey $rbutton up,off      ; list whatever mouse buttons you want tracked.
		if(use_mbuton) hotkey $mbutton up,off      ; works best if all available listed
		hotkey $xbutton1 up,off         ; lbutton only tracked when other mouse buttons start tracking
		hotkey $xbutton2 up,off

		hotkey $WheelUp,off
		hotkey $WheelDown,off		
	}
return
}

; /**************************************************************************************************/


mouse_button:
{
;	if (DemonScroll)
;		return

	if not(includeVirtual or GetKeyState("RButton", "P") )
		return ;skip virtual clicks from touch

		k:=A_ThisHotkey="$xbutton2" ? "f" : substr(A_ThisHotkey,2,1)	
 
	if ( buttons=="") ; inicializamos el demonio de gestures
	{
		if winactive("ahk_group disabled_group")
		{
			if a_thishotkey=$rbutton
				click down right
			else if a_thishotkey=$mbutton
				click down middle
			else {
				StringTrimLeft, temp_mbutton_, a_thishotkey, 1
 				send,{%temp_mbutton_%}
			}
			return
		}
		gosub startDemon
	}
	else
		if (clickTime1 -clickTime2 > MulticlickTime )
			buttons:=buttons . "/"	
	if (gestures<>"") ; añadir los botones a la cola
	{
		buttons:=buttons . "(" . gestures . ")" . k
		gestures:=""
	} else
		buttons:=buttons . k
return
}

mouse_button_up:
{
/*
	if (DemonScroll)
	{
		SetTimer sDemonScroll,Off
		setMousePos("last")
		if (mousePosY_first==mousePosY_last) And (mousePosX_first==mousePosX_last)
			click up right
			;Send, {RButton up} 
		DemonScroll:=false
		buttons := ""
		return
	}
*/

	if ( buttons == "" )
	{
		if a_thishotkey=$rbutton up
			click up right
		else if a_thishotkey=$mbutton up
			click up middle
		else {
			StringTrimLeft, temp_mbutton_, a_thishotkey, 1
			send,{%temp_mbutton_% up}
		}
		return
	}
	setMousePos("last") ; posicion y controles sobre los que se encuentra el mouse al hacer click por primera vez; necesario para el scroll y comandos 
	k:=A_ThisHotkey="$xbutton2 up" ? "f" : substr(A_ThisHotkey,2,1)
	if (gestures<>"")
	{
		buttons:=buttons . "(" . gestures . ")" . "^" . k
		gestures:=""
	} else
		buttons:=buttons . "^" . k		
	if ( not ( getkeystate("LButton","P") Or getkeystate("RButton","P") Or getkeystate("MButton","P")) ) 
	{			
		if ( wheel == "" )
			gosub exec
		gosub stopDemon
	}
return
}

mouse_wheel:
{
	setMousePos("last") ; posicion y controles sobre los que se encuentra el mouse al hacer click por primera vez; necesario para el scroll y comandos
	if (buttons=="") {
		if ( getkeystate("LButton","P") )
			gosub startDemon
	}
	wheel:= substr(a_thishotkey,2)
	gosub exec	
return
}

; /**************************************************************************************************/

demonGestures:
{
	setMousePos(2) ; guardar la posicion actual del mouse	
	if ( getDistance(mousePosX_1,mousePosY_1,mousePosX_2,mousePosY_2) >= minDistance )
	{ 
			cdir:=getDirection(mousePosX_1,mousePosY_1,mousePosX_2,mousePosY_2)
			cdir:=cdir%cdir%
			if ( detectLong )
				gestures:=gestures . cdir
			else
				if ( lastDir != cdir )					
					gestures:=gestures . cdir
			lastDir:=cdir
			setMousePos(1) ; definir un nuevo punto de inicio		
			setMousePos(3)			
			dir1=5
			inactivityTimeCount=0
	} 
	else if ( getDistance(mousePosX_3,mousePosY_3,mousePosX_2,mousePosY_2) >= minStep )
	{ 			
		dir2:=getDirection(mousePosX_3,mousePosY_3,mousePosX_2,mousePosY_2)
		if ( dir1==5)
			dir1:=dir2
		if  ( dir1<>5 And dir1<>dir2 And ( abs(dir1-dir2) <> 4 And abs(dir1-dir2)<>1) ) ; si se cambia de direccion repentinamente se vuelve a definir un punto de inicio
		{	
			setMousePos(1)
			dir1:=dir2
		}
		setMousePos(3)
		inactivityTimeCount=0		
	} else { 	
		if ( inactivityTimeCount>inactivityTime)
		{
			setMousePos(1) ;end current gesture
			inactivityTimeCount=0
			if ( wheel == "")  ;cancel gesture only if the wheel wasn't used
			{
				if ( execAfterInactivityTime ) 
				{
					if (gestures<>"")
						buttons:=buttons . "(" . gestures . ")" . "..." 
					else
						buttons:=buttons . "..."				
					gestures:=""
					gosub exec
				}
				gosub stopDemon
			}
		} else {
				inactivityTimeCount++
		}		
	}
	return
}
	
sDemonScroll:
{
	setMousePos(2)
	mx:=mousePosY_1-mousePosY_2 
	if mx >= 15
	   { 
		Sendinput, {WheelUp}
		setMousePos(1)
	   } 
	else if mx <= -15
	   { 
	   Sendinput, {WheelDown}
		setMousePos(1)
	   } 
return 
} 

startDemon:
{
/*
	setMousePos("first") ; posicion y controles sobre los que se encuentra el mouse al hacer click por primera vez; necesario para el scroll y comandos	
	if (mousePosX_first<=10) Or (mousePosX_first>=monWidth-10)
	{ 
		DemonScroll:=true
		setMousePos(1)
		SetTimer sDemonScroll,20
		return
	} 
*/
	hotkey,lbutton,on  ;enable control over lbutton
	hotkey,lbutton up,on	
	if ( getkeystate("LButton","P"))
	{
		buttons=l
		click up
		;sendinput {click up}	
	}
	setMousePos("first")
	setMousePos(3) ; posicion y controles sobre los que se encuentra el mouse; necesario para detectar los cambios de direccion repentino
	setMousePos(2) ; posicion y controles sobre los que se encuentra el mouse; necesario para detectar la direccion del gesto (punto actual)
	setMousePos(1) ; posicion y controles sobre los que se encuentra el mouse; necesario para detectar la direccion del gesto (punto inicial)	
	cursor_first:=CursorCheck()
	dir1=5
	lastDir=_
	inactivityTimeCount=0
	gestures:=""
	wheel:=""
	SetTimer demonGestures,%waitTime%
return
}


stopDemon:
{
	SetTimer demonGestures,off
	hotkey,$lbutton,off		;disable control over lbutton	
	hotkey,$lbutton up,off
	;if ( substr(buttons,1,1) == "l" )
	;if ( buttons == "l" )
		;sendinput {click up}	
	buttons:=""	
	wheel:=""
	setMousePos("last") ; posicion y controles sobre los que se encuentra el mouse al hacer click por primera vez; necesario para el scroll y comandos 		
	/*
	if ( getkeystate("LButton","P") )
	{
		hotkey,$lbutton up,nothing
		click up
		;sendinput {lbutton up}
		hotkey,$lbutton up,off
	}
	if ( getkeystate("RButton","P") )
	{
		hotkey,$rbutton up,nothing
		click up right
		;sendinput {rbutton up}
		hotkey,$rbutton up,mouse_button_up
	}
	if ( getkeystate("MButton","P") )
	{
		hotkey,$mbutton up,nothing
		click up middle
		;sendinput {mbutton up}
		hotkey,$mbutton up,mouse_button_up
	}
	*/
	
return
}
	
setMousePos(n)
{
	global 
	if( n == 1)
	{
		mousePosX_1:=mousePosX_2
		mousePosY_1:=mousePosY_2		
	}
	else
	{
		 
		;MouseGetPos, mousePosX_%n%, mousePosY_%n% 
		;window_%n% := DllCall( "WindowFromPoint", "int", mousePosX_%n%, "int", mousePosY_%n% )
		
		mousegetpos mousePosX_%n%,mousePosY_%n%,window_%n%,control_%n%
	}
}

getDistance(X1,Y1,X2,Y2)
{	
	return abs(X1-X2) + abs(Y1-Y2) ; yeah... I know....
}

getDirection(X1,Y1,X2,Y2)
{
	global T,T2
	dx:=X2 - X1 + 0.1 ; se añade 0.1 para evitar una divicion por cero
	dy:=Y1 - Y2	
	dT:=abs(dy/dx)	
	if ( dT<T)
		if (dx>0)
			track=6 ;r ;6
		Else
			track=4 ;l ;4
	else	
		if ( dT>T2 )
			if ( dy > 0)			
				track=9 ;u ;8
			Else
				track=1 ;d ;2
		Else
			if (dx>0)
				if ( dy >0)
					track=10 ;9 ;ur
				Else
					track=2 ;3 ;dr
			Else
				if ( dy>0)
					track=8 ;7 ; ul
				Else
					track=0 ;1 ; dl
	return track
}

initialize:
{
	cdir0=1
	cdir1=d
	cdir2=3
	cdir4=l
	cdir6=r
	cdir8=7
	cdir9=u
	cdir10=9
	if ( minDistance<minStep )
		minStep:=minDistance*3/2
	inactivityTime:=round(inactivityTime/waitTime+0.3)
	limitAngle:=limitAngle*3.14159265358979/180 ;convirtiendo el anguloLimite para acelerar las operaciones
	T:=tan(limitAngle) ;"caching" converciones
	T2:=1/( T+0.0000001 ) ; idem
	clickTime1:=a_tickcount		;ultimo click
	
	SysGet, mon, MonitorWorkArea, %m% 
    monWidth  := monRight - monLeft 
    monHeight := monBottom - monTop
	
	hotkey $lbutton,mouse_button 	;disable control over lbutton; necesary to enable drag&drop
	hotkey $rbutton,mouse_button      ; list whatever mouse buttons you want tracked.
	if(use_mbuton) hotkey $mbutton,mouse_button      ; works best if all available listed
	hotkey $xbutton1,mouse_button         ; lbutton only tracked when other mouse buttons start tracking
	hotkey $xbutton2,mouse_button
	
	hotkey $lbutton up,mouse_button_up 	;disable control over lbutton; necesary to enable drag&drop	
	hotkey $rbutton up,mouse_button_up      ; list whatever mouse buttons you want tracked.
	if(use_mbuton) hotkey $mbutton up,mouse_button_up      ; works best if all available listed
	hotkey $xbutton1 up,mouse_button_up         ; lbutton only tracked when other mouse buttons start tracking
	hotkey $xbutton2 up,mouse_button_up


	hotkey $WheelUp,mouse_wheel
	hotkey $WheelDown,mouse_wheel
	
	hotkey $lbutton,off		;disable contorl over lbutton; necesary to enable drag&drop
	hotkey $lbutton up,off

return
}

exec:
{
	macro:=""
	if ( wheel <> "" )
	{
		if ( buttons <> "" ) 
		{
			if (gestures<>"") ; añadir los botones a la cola
				macro:="m-" . buttons . "(" . gestures . ")" . "-" . wheel
			else 
				macro:="m-" . buttons . "-" . wheel
		} else 
			macro:="m-" . wheel				
	} else
			macro:="m-" . buttons
	if ( islabel(macro) )  ; checks if macro is labelled
		gosub %macro%
	Else	
	{
		if (copyMacro)
			Clipboard:=macro			
		if (showGuide)
			showTooltip( macro . (copyMacro ? " (copiado) " : "" )  )			
		if ( back2default ) ;go to simple action			
		{
			if ( wheel <> "" ) 
				return
			macro:=SubStr(macro,1,3) . "^" . SubStr(macro,3,1) ;m-l^l ; m-m^m ; m-r^r 
			if (islabel(macro) )  ; checks if macro is labelled
				SetTimer, %macro%, -1 
				;gosub %macro%	
		}	
	}	
return
}

; /**************************************************************************************************************/

showTooltip(msg)
{
	global
	tooltip %msg%
	settimer hideTooltip,%tooltipTime%	
}

hideTooltip:
{
	settimer hideTooltip,off
	tooltip
	return
}

CursorCheck()  ; 
{ 
VarSetCapacity(mi, 20, 0) 
mi := chr(20) 
DllCall("GetCursorInfo", "Uint", &mi) 
hCursor:= NumGet(mi, 8)
return hCursor 
}

debug:
{
	l:=getkeystate("LButton","P")
	r:=getkeystate("RButton","P")
	m:=getkeystate("MButton","P")
	cursor1:=cursorCheck() 

	WinGetClass, class_f, ahk_id %window_first%
	WinGetClass, class_l, ahk_id %window_last%

	ToolTip %buttons% ( %l%|%r%|%m% %wheel%) [ %gestures% ]   %macro%   cursor: %cursor_first% < %cursor1% >  --- %class_f% -- %class_l% ,6
return
}








































;**************************************************************************************************
;**                                                                                                                                                                                            **
;**                                                                                 Gestures                                                                                            **
;**                                                                                                                                                                                            **
;**************************************************************************************************


;**************************************       custom Gestures          *****************************
;		l	 /		7	u	9		\
;m - m	|		l		r		|		:
;		r	 \		1	d	3		/	






; /************************* basics ********************************/
; click izq funciona normalmente, para saltarse el control del mouse presione alguna tecla modificadora mientras hace click
;window_first=ventana donde empieza el gesto ;  mousePosX_first,mousePosY_first = donde empieza el gesto ; control_first=control donde empieza el gesto ; 
;window_last=ventana donde termina el gesto ;  mousePosX_last,mousePosY_last = donde termina el gesto ; control_last=control donde termina el gesto ; 
;cursor_first = id del cursor en el momento que empieza el gesto


;************** syntax: ***********
; m- : identifier of the gesture
; r : mouse right button down
; ^r : mouse right button up
; (d) : direction of the mouse movement d=r,l,u,d,1,2,3,4,6,7,8,9
;                                             
;                             (up/arriba)                   
;                               u or 8                   
;
;                           6              7          
;
;   (right/derecha) l or 4                   r or 6 (left/izquierda)            
;
;                           1              3           
;
;                               d or 2                  
;                             (down/abajo)                   
;
;
;(12323) : directions first 1 then 2 then 3 the 2 then 3 (no limit)
;WheelDown:WheelDown
;WheelUp:WheelUp
;
;
;************* capture gesture *********
;
; (windows button)+(shift)+D   (#+d )shows the debug window
;  now draw any gesture and the windwo will show the gesture begin traced while the button is pressed
;  if they arent associated with any command at the button release will execute the normal command
;    


;m-r/l^l:		;fix for strange behaviour with touch screens
m-r^r:         ;normal right click
{
mouseclick right
return
	;winactivate ahk_id %window_first%   
	;if winactive("ahk_group browser_group") and ( cursor_first == 65567 ) ;hand over urls
	if winactive("ahk_group browser_group") and ( cursor_first <> 65541 and cursor_first <> 65539  ) ; ;aynthing but default cursor a text
	{
		mouseclick middle
		;mouseclick middle,mousePosX_first,mousePosY_first
		;mousemove mousePosX_last,mousePosY_last,0
	}
	else{

		mouseclick right
		;mouseclick right,mousePosX_last,mousePosY_last		
	}
	msgbox %cursor_first% 
return
}



m-m^m:		;normal middle click
{       
	;winactivate ahk_id %window_first%   
	if WinActive("ahk_group explorer_group")
		mouseclick left,,,2		
	else
		mouseclick middle
	/*
	if WinActive("ahk_group explorer_group")
		mouseclick left,mousePosX_first,mousePosY_first,2		
	else
		mouseclick middle,mousePosX_first,mousePosY_first
	mousemove mousePosX_last,mousePosY_last,0
	*/
return
}

m-WheelDown:
{
;	sendinput {wheelDown}
;return
	WinGetClass, class, ahk_id %window_last%
	if class=VNCMDI_Window
		sendinput {wheelDown}		
	;else if class=Shell_TrayWnd
	;	sendinput ^!{tab}
	else if class=wxWindowClassNR
		sendinput {wheelDown}		
	else if class=TscShellContainerClass
		sendinput {wheelDown}		
	else	
		SendMessage, 0x20A, -120 << 16, ( mousePosY_last << 16 )|mousePosX_last,%control_last%, ahk_id %window_last%
return
}

m-WheelUp:
{	
;sendinput {wheelup}
	
;return
	WinGetClass, class, ahk_id %window_last%	
	if class=VNCMDI_Window
		  sendinput {wheelUp}
	;else if class=Shell_TrayWnd
	;	sendinput ^+!{tab}	
	else if class=wxWindowClassNR
		  sendinput {wheelUp}
	else if class=TscShellContainerClass
		sendinput {wheelUp}	
	else
		SendMessage, 0x20A, 120 << 16, ( mousePosY_last << 16 )|mousePosX_last,%control_last%, ahk_id %window_last%
return
}




;/*************************** advanced **********************************/


m-r(ld)^r: ;alttab
m-r(l1d)^r:
{
;	sendinput {alt down}{tab}{alt up}
	sendinput {control down}{f1}{control up}
Return
}

m-r(lu)^r: ;subir al nivel superior ; explorer
m-r(l7u)^r:
{
	winactivate ahk_id %window_first%   
	sendinput {alt down}{up}{alt up}
;	send ^{f1}
Return
}

m-r(l)^r:  ;forward
{
	winactivate ahk_id %window_first%   	
	sendinput,{alt down}{left}{alt up}
return
}

m-r(r)^r:      ;backward
{  
	winactivate ahk_id %window_first%   
	sendinput,{alt down}{right}{alt up}
return
}

m-r(ur)^r: ;prev tab
m-r(u9r)^r:
m-r(u9)^r:
{
	winactivate ahk_id %window_first%   
	sendinput,{control down}{tab}{control up}
return
}
m-r(ud)^r: ;f12
{
	winactivate ahk_id %window_first%   
	sendinput,{f12}
return
}
m-r(udu)^r: ;f11
m-r(dud)^r:
{
	winactivate ahk_id %window_first%   
	sendinput,{f11}
return

}
m-r(ul)^r: ;next tab
m-r(u7l)^r:
m-r(u7)^r:
{
	winactivate ahk_id %window_first%   
	sendinput,{control down}{shift down}{tab}{shift up}{control up}
return
}

m-r(du)^r: ;open in new tab ; middle click
;m-r(d)^r:
{
	if ( cursor_first == 65567 ) ;url
	{ 
		mouseclick middle,mousePosX_first,mousePosY_first
		mousemove mousePosX_last,mousePosY_last,0
	}
	else	 	;if ( cursor0 = 65539 )  ;default
	{
		winactivate ahk_id %window_first%   
		sendinput {control down}t{control up}
	}	
Return
}

m-r(dr)^r:          ;cerrar pestaña
m-r(d3r)^r:           
m-r(d3)^r:           
{
	winactivate ahk_id %window_first%   
;	sendinput {control down}{f4}{control up}
	sendinput {control down}w{control up}
return
}

m-r(dl)^r: ;deshacer pestaña cerrada
m-r(d1l)^r:
m-r(d1)^r:
{
	winactivate ahk_id %window_first%   
	sendinput {control down}{shift down}{t}{shift up}{control up}
return
}


m-r(lr)^r: ;refresh page
{
	winactivate ahk_id %window_first%   
	sendinput {f5}
return
}



m-r(ldr)^r:            ;close window under cursor (draw a C)
m-r(l1d3r)^r:
m-r(l1dr)^r:
m-r(ld3r)^r:
{
	winactivate ahk_id %window_first%
	winclose, A   
	;sendinput {alt down}{f4}{alt up}
return
}


m-r(rdl)^r: ; C invertida; guardar documento actual
m-r(r3d1l)^r:
m-r(r3dl)^r:
m-r(rd1l)^r:
{
	winactivate ahk_id %window_first% 
	sendinput {control down}s{control up}
return
}

m-r(ru)^r: ;ir al comienzo de la página
m-r(r9u)^r:
{
	winactivate ahk_id %window_first% 
	sendinput {control down}{home}{control up}
return
}

m-r(rd)^r: ;ir al final de la página
m-r(r3d)^r:
{
	winactivate ahk_id %window_first% 
	sendinput {control down}{end}{control up}
return
}

m-r(1)^r: ;undo
{
	winactivate ahk_id %window_first% 
	sendinput {control down}z{control up}
return
}

m-r(3)^r: ;redo
{
	winactivate ahk_id %window_first% 
	sendinput {control down}y{control up}
return
}

m-lr^r^l: ;rocket gestures, or simulate middle click with left and right click
m-lr^l^r:
m-lr^l: 
m-rl^l:
{        
	winactivate ahk_id %window_first%   
	;if winactive("ahk_group browser_group") and ( cursor_first == 65567 )
	;	mouseclick middle,mousePosX_first,mousePosY_first
	;else
		sendinput,{alt down}{Right}{alt up}
return
}

m-rl^l^r: ;rocket gestures, or simulate middle click with left and right click
m-rl^r^l:
{        
	winactivate ahk_id %window_first%   
	;if winactive("ahk_group browser_group") and ( cursor_first == 65567 )
	;	mouseclick middle,mousePosX_first,mousePosY_first
	;else
		sendinput,{alt down}{Left}{alt up}
return
}


+#d::
m-r(rdlu)^r:
m-r(dlur)^r:
{
	if (debug)
	{
		debug:=False
		SetTimer debug,off
		tooltip 
	}
	Else
	{
		debug:=True
		SetTimer debug,100
	}
Return
}

m-r(ldru)^r:
m-r(drul)^r:
{
	ToolTip reloading mouse gestures
	sleep 750	
	Reload
return
}

m-lm^m^l: 
{
	winactivate ahk_id %window_last%   
	sendinput {control down}{Numpad0}{control up}
return
}


m-l-WheelUp:
{	

;	sendinput {wheelup}
;	return
;	winactivate ahk_id %window_last%   
	sendinput {control down}{NumpadAdd}{control up}
return
}

m-r-WheelUp:
{	
	winactivate ahk_id %window_last%   
	sendinput {PgUp}

;	winactivate ahk_id %window_last%   
;	sendinput {control down}{shift down}{tab}{shift up}{control up}
return
}


m-l-WheelDown:
{	

;	sendinput {wheeldown}
;	return
	winactivate ahk_id %window_last%   
	sendinput {control down}{NumpadSub}{control up}
return
}

m-r-WheelDown:
{
	winactivate ahk_id %window_last%   
	sendinput {PgDn}

;	winactivate ahk_id %window_last%   
;	sendinput {control down}{tab}{control up}
return
}
/*
m-m-WheelUp:
{
	winactivate ahk_id %window_last%
	sendinput {f11}
return
}

m-m-WheelDown:
{
	winactivate ahk_id %window_last%
	sendinput {alt down}{F4}{alt up}	
return
}
*/
m-r(u)-WheelUp:
{

	winactivate ahk_id %window_last%   
	sendinput {control down}{tab}{control up}
return
}

m-r(u)-WheelDown:
{
	winactivate ahk_id %window_last%   
	sendinput {control down}{shift down}{tab}{shift up}{control up}	
return
}

m-r(d)-WheelUp:
{
	sendinput {Volume_Up}	
return
}

m-r(d)-WheelDown:
{
	sendinput {Volume_Down}	
return
}
m-r(l)-WheelUp:
{
	sendinput {Media_Prev}	
return
}

m-r(l)-WheelDown:
{
	sendinput {Media_Next}	
return
}

m-r(r)-WheelUp:
{
	IfWinExist ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
		sendinput {lwin down}{alt down}{right}{alt up}{lwin up}
;		sendinput {control down}{shift down}{right}{shift up}{control up}
return
}

m-r(r)-WheelDown:
{
	IfWinExist ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
		sendinput {lwin down}{alt down}{left}{alt up}{lwin up}
;		sendinput {control down}{shift down}{left}{shift up}{control up}
return
}

m-r(ud)-WheelDown:
m-r(du)-WheelDown:
{
	sendinput {alt down}{shift down}{Esc}{shift up}{alt up}
return
}


m-r(ud)-WheelUp:
m-r(du)-WheelUp:
{
	sendinput {alt down}{Esc}{alt up}
return
}






;**************************************************************************************************
;**                                                                                                                                                                                            **
;**                                                                                 PATCHES                                                                                            **
;**                                                                                                                                                                                            **
;**************************************************************************************************







!x::
 hotkey x,null
 hotkey s,null
 hotkey s,off
 settimer kscrollup,off
 settimer kscrolldown,50
return
kscrolldown:
	if not( getkeystate("x","P") )
	{
		settimer kscrolldown,off
		hotkey x,off
		return
	}
;	send {wheeldown}
	setMousePos("last")
	gosub m-WheelDown
return
!s::
 hotkey s,null
 hotkey x,null
 hotkey x,off
 settimer kscrolldown,off
 settimer kscrollup,50
return
kscrollup:
	if not( getkeystate("s","P") )
	{
		settimer kscrolldown,off
		hotkey s,off
		return
	}
	setMousePos("last")
	gosub m-WheelUp
;	send {wheelup}
return

null:
return
