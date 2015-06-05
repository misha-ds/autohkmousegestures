Autohkmousegestures v2.1

Configurable mouse gestures with Autohotkey http://www.autohotkey.com/

support:
- unlimited number of gestures
- support 8 directions for gestures
- configurable length of gestures (pixels dragged)
- recognize what mouse cursor it's used at the start of a gesture
- recognize what window and control are under the cursor at the start of the gesture
- allow combination of buttons (rocket gestures) between gestures
- allow use of scroll between gestures
- has a custom debug to record gestures
- 


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

;example
m-r(u)-WheelUp:  ; right button->up->wheelup
{
   ;actions 
}
m-r(ldru)^r: ; right button->left->down->right->up   (box)
m-r(drul)^r: ; right button->down->right->up->left   (box)
{
   ;actions 
}

m-rl^l^r: ;rocket gestures press right->press left->release right
m-rl^r^l:
{
   ;actions 
}
m-r(ldr)^r:    ; c shape : right button->left->down->right
{
   ;actions 
}