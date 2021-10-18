


IDEAL
MODEL Small
STACK 1024 
	
INCLUDE "c:\gvahim\gvahim.mac"



DATASEG
;files used for different screens 
start db "Intro.BMP ",0
help db "help.bmp",0
help2 db "help2.bmp",0
draw db "draw.bmp",0
current db "current.bmp",0 
colorp db "colorp.bmp",0 
lastsave db "lastsave.bmp",0 
;Bmp file opening
;Different readings from file  
filehandle dw ?
header db 54 dup(0)       
pallete db 400h dup(0)
Line db 320 dup(0)
openfile db 100 dup(0)
prompty db "Enter filename to open(Filename.bmp)",0
promptx db "Enter filename to save to(filename.bmp)",0  
prompt2 db "Type q to return",0 
prompt3 db "Type lastsave.bmp for last work ",0 
no_file db "No file was found with that name",0 
;Random data 
;Color1 being used 
color db 0 
;Current mode 
mode db 0
error1 db 0
old db ? 
point1X dw ? 
point1Y dw ? 
point2X dw ? 
point2y dw ?
exit db 0 
;Used to store value of ? for bucket fill algorithm(recursion)
stack_bucket db 16000 dup (?)
;--------------------------------------------------------------------------------------
; Begin Instructions 
;--------------------------------------------------------------------------------------
CODESEG
ENTRY: 

	;; Load data segment to DS
	mov  ax, @DATA
	mov  ds, ax
	
	graphics:
	mov ah,0 ;Sets graphic mode 
    mov al,13h
    int 10h
	
	;---------------------------------------------------------------------------------
	;This part of the program contains all the menus that can be opened
	;----------------------------------------------------------------------------
main_menu:
;Main_Menu File 
    mov dx,offset start 
	call BmpFile
	
	;Checks for next step 
loop1:
  ;Checks for Key_Stroke 
	 call Get_Key_Press
	 call Case_Insensitive
	 ;Open new work 
	 cmp al,13 
	 je new_screen_jmp1
	 
	 ;Open_Help_Menu 
	 cmp al,'h'
	 je help_manual
	 
	 ;Exit 
	 cmp al,""
	 je term
	 
	 ;Open old work 
	 cmp al,'o'
	 je open_work 
	 jmp loop1
	 
	 ;Opens starting help menu 
help_manual:
    call Help_Menu_In
    jmp new_screen
	new_screen_jmp1:
	jmp new_screen_jmp
    ;Open work  
open_work:
    ;Text mode 
	mov ah,0
	mov al,0 
	int 10h 
	
    call Open_Pic
	cmp [exit],1 
	je main_menu
	jmp color_change
	
new_screen_jmp:
	 jmp new_screen
term:
	 jmp termi
main:
     call Hide_Mouse_Pointer
	 jmp main_menu

	 ;-------------------------------------------------------------
	 ;This is the main program loop
	 ;------------------------------------------------------------
	;Draws new screen 
new_screen:
	 mov dx,offset draw  
	 call BmpFile
	 call Show_Mouse_Pointer
	 
	 ;Changes color square at bottom left of screen 
color_change:
	 mov cx,1 
	 mov dx,176   
	 
    square_loop:
	 call set_pixel
	 inc cx 
	 cmp cx,16 
	 jne square_loop
	 inc dx 
	 mov cx,0 
	 cmp dx,192
	 jna square_loop
	
	 call Second_Pause
	 
	;Short keys check 
begin:
	call Get_Key_Press
	call Case_Insensitive
	cmp al,""
	jne p 
	call Hide_Mouse_Pointer
    mov si,0 
	looplastsave1:
	mov al,[lastsave+si]
	cmp al,0 
	je Save_Last1 
	mov [openfile+si],al
    inc si 
    jmp looplastsave1
	
	Save_Last1:
	call Save_Pic
	call Show_Mouse_Pointer
	jmp main
	
	p:
	cmp al,'p'
	jne e
	mov [mode],1  
	jmp command
	
	;e=eraser 
e:
	cmp al,"e"
	jne s
	mov [mode],2 
	jmp command
	;s=square 
s:
	cmp al,"s"
	jne g
	mov [mode],6 
	;Get_Color Mode 
g:
	cmp al,'g'
	jne c 
	mov [mode],3 
	jmp command

begin1:
jmp begin 	
	;On double tap,clears screen. In case of accidental erase 
c:
	cmp al,'c'
	jne l
	call Second_Pause
	call Get_Key_Press
	cmp al,'c'
	jne command
	jmp new_screen
;Line mode 
l:
   cmp al,'l'
   jne b 
   mov [mode],4 
   jmp command 
;Bucket_fill mode 
b:
  cmp al,'b'
  jne k 
  mov [mode],5
  jmp command

k:
cmp al,'k' 
jne o 
jmp colorchoosing

o:
cmp al,'o'
jne h 
jmp open_old  

h:
cmp al,'h' 
jne command
jmp hehe 

;Checks for mouse click   
command:
	call Mouse
	cmp bx,1 
	jne begin1
	
	cmp cx,319 
	ja begin1
;Checks if mouse was pressed on bottom tool bar 	
	cmp dx,174 
	jae bottom
;Checks if mouse was pressed on color tool bar 	
check_for_vertical:
	cmp cx,28 
	ja check_color
;Checks what mode was pressed 	
	cmp dx,150 
	jb pencil_check 
	mov [mode],4
	jmp begin
	;Checks if pencil icon was pressed 
pencil_check:
	cmp dx,122 
	jb sqaure_check 
	mov [mode],1 
	jmp begin
	;Checks if square icon was pressed 
sqaure_check:
	cmp dx,91 
	jb sucker
	mov [mode],6 
	jmp begin 
    ;Checks if get_color icon was pressed 
	sucker:
    cmp dx,59 
	jb eraser_pressed
	mov [mode],3 
	jmp begin  
	;Checks if eraser was pressed 
    eraser_pressed:
	cmp dx,29 
	jb bucket_fill
	mov [mode],2 
	jmp begin 
	;Checks if bucket fill was pressed 
	bucket_fill:
	mov [mode],5 
	jmp begin 
	passage10:
	jmp begin
;Checks if color bar was pressed  
	check_color:
    cmp dx, 20 
	;If not,jump to section of code that deals with the screen 
	ja screen_pas 
	cmp cx,251 
	ja passage10
	;Hide mouse 
	call Hide_Mouse_Pointer 
	;Get color 
	call Get_Color1
	mov [color],cl
	call Show_Mouse_Pointer
	jmp color_change

passage4:
	jmp begin 
color_pas:
jmp color_change		
screen_pas:
   jmp screen 
	
;Checks what was pressed on bottom tool bar 	
bottom:
	cmp cx,286 
	jb thicknessdown
	call Hide_Mouse_Pointer
    mov si,0 
	looplastsave:
	mov al,[lastsave+si]
	cmp al,0 
	je Save_Last 
	mov [openfile+si],al
    inc si 
    jmp looplastsave
	
	Save_Last:
	call Save_Pic
	call Show_Mouse_Pointer
	jmp main
	
thicknessdown:
	cmp cx,222  
	jb help_save
	jmp passage4 
	
	color_pas1:
	jmp color_pas
	;Opens help menu 
help_save:
	cmp cx,189
	jb open_old
	
	hehe:
	call Hide_Mouse_Pointer
	
	mov si,0 
	call Current_Save
	call Save_Pic
	
	call Help_Menu_In
	mov dx,offset current
	call BmpFile
	
	call Show_Mouse_Pointer
	call Second_Pause
	call Second_Pause
	jmp begin
	 
open_old:
	cmp cx,132 
	jb save_new
	
	call Hide_Mouse_Pointer
	
	call Current_Save
	call Save_Pic
	
	call Open_Pic
	cmp [exit],1 
	jne color_pas1
	
	call Hide_Mouse_Pointer
	
	mov dx,offset current
	call BmpFile
	
    call Show_Mouse_Pointer	
	jmp begin
	
;Missing;Need to work on 
;Save file 
save_new:
	cmp cx,80 
	jb New_File
	
	call Hide_Mouse_Pointer
	
	call Current_Save
	call Save_Pic
	
	mov ah,0
	mov al,0 
	int 10h
	
	lea si,[promptx]
	call Print_Str
	call New_Line
	
	lea si,[prompt2]
	call Print_Str
	call New_Line
	
	mov cx,15 
	lea si,[openfile]
	call Scan_Str
	
	mov si,0 
	cmp [openfile+si],'q'
	jne no_exit1 
    inc si 
    cmp [openfile+si],0 
    jne no_exit1 
	 
	mov ah,0 ;Sets graphic mode 
    mov al,13h
    int 10h
	
	mov dx,offset current
	call BmpFile
	call Show_Mouse_Pointer
	
	jmp begin
	
	no_exit1:
	mov dx,offset openfile 
	mov ah,3ch
	mov cx,7 
	int 21h
	
	mov ah,0 ;Sets graphic mode 
    mov al,13h
    int 10h
	
	mov dx,offset current 
	call BmpFile
	
	mov dx,offset openfile
	call Save_Pic
	
	call Show_Mouse_Pointer
	jmp begin 
	;Opens new work 
	
New_File:
    cmp cx,32
	jb colorchoosing 
    jmp new_screen
	
	colorchoosing:
	call Hide_Mouse_Pointer
	
    call Current_Save
	call Save_Pic
	 
	mov dx,offset colorp 
	call BmpFile
	call Show_Mouse_Pointer
	
	@@colorpickloop:
	call Mouse
	cmp bx,1 
	jne @@colorpickloop
	
	cmp dx,43 
	jb @@colorpickloop
	
	cmp dx,194 
	ja @@colorpickloop
	
	cmp cx,51 
	jb @@colorpickloop
	
	cmp cx,270  
	ja @@colorpickloop
	
	mov ax,2 
	int 33h 
	call Get_Color1
	mov [color],cl 
	mov dx,offset current
	call BmpFile
    call Show_Mouse_Pointer
	jmp color_change
	
	
passage3:
	jmp passage4
passage:
    call Hide_Mouse_Pointer
	jmp new_screen
passage7:
	jmp passage3	
passage8:
jmp color_change

;Checks what mode is in current use and checks on screen  	
screen:
	mov [point1X],cx 
	mov [point1Y],dx 
	
	cmp [mode],0 
	je passage3
	;If current moode is pencil,call Pencil 
    cmp [mode],1 
	jne erasermode

	call Pencil
	jmp passage3
	;If current mode is eraser,call Eraser
erasermode:
	cmp [mode],2 
	jne get_color 
	call Eraser
	jmp Passage7
	;If current mode is get_color,call Get_Color
get_color:
	cmp [mode],3 
	jne line_mode
	
	call Hide_Mouse_Pointer
	
	call Get_Color1
	
	mov [color],cl 
    call Show_Mouse_Pointer
	jmp passage8 
	;If current mode is line-get line 
line_mode:
	cmp [mode],4 
	jne buckketmode


@@loop1:
	call Mouse
	cmp bx,1 
	je @@loop1
	cmp cx,28 
	jb nodraw
	cmp dx,178 
	ja nodraw
	cmp dx,23 
	jb nodraw
	
    call Hide_Mouse_Pointer
    call DrawLine
nodraw:
    call Show_Mouse_Pointer
	jmp passage7 
	
passage9:
	jmp Passage7 
	
 
	
buckketmode:
	cmp [mode],5 
	jne squaremode
	push cx 
	call Hide_Mouse_Pointer
    call Get_Color1
	mov ah,cl 
	pop cx 
	cmp ah,[color]
	je no_need_for_fill
	call Bucket_Fill1
	
no_need_for_fill:
	call Show_Mouse_Pointer 
	jmp passage7 
	
squaremode:
	cmp [mode],6 
	jne Passage9
	call Draw_Square
	jmp passage7
	
termi:
	call Terminate
	mov  ax, 4c00h
	int  21h		
	
	
;----------------------------------------------------------------------------------------
;Help_Menu_In()-Opens a help manual on-screen 
;Input:NONE
;Output:None
;----------------------------------------------------------------------------------------
proc Help_Menu_In
 help_menu:
     mov dx,offset help
	 call BmpFile
	 
	 call Show_Mouse_Pointer
     call Second_Pause
	 
 loop2:
     call Mouse
	 cmp bx,1 
	 jne loop2
	 cmp dx,175 
	 jb loop2
	 cmp cx,278 
	 ja next_screen
	 cmp cx,43 
	 ja loop2
	 ;Hides mouse pointer
	 call Hide_Mouse_Pointer 
	 jmp @@end_func
	 
 next_screen:
	 mov ax,2 
	 int 33h 
	 mov dx,offset help2
	 call BmpFile
	 mov ax,1; Shows mouse pointer 
     int 33h
	 
	 ;Needs to wait a second. Otherwise it automatically switches back to main menu 
    call Second_Pause
	 
 loop3:
	 call Mouse
	 cmp bx,1 
	 jne loop3
	 
	 cmp dx,175 
	 jb loop3
	 cmp cx,43 
	 jb hide
	 cmp cx,278 
	 jb loop3
	 
	 call Hide_Mouse_Pointer
	 jmp @@end_func
	 
 hide: 
	 call Hide_Mouse_Pointer
	 jmp help_menu
	 
 @@end_func:
	 ret 
	endp Help_Menu_In
	
	
;----------------------------------------------------------------------------------------
;BmpFile()-Prints Bmp picture saved in file to screen
;Input: Dx-offset filenam 
;Output:None 
;----------------------------------------------------------------------------------------
proc BmpFile
mov [error1],0 
	call Open_File
	cmp [error1],1 
	je @@nofilefound
	call Header1
	call Palette
	call Video
	call Print 
	call Close_File
	@@nofilefound:
ret 

endp BmpFile


;----------------------------------------------------------------------------------------
;Open_File()-Opens file
;Input: DX-offset filename  
;Output:FIle handle
;----------------------------------------------------------------------------------------
proc Open_File
;Interupt to open file 
mov al,2 
mov ah,3dh 
int 21h
;carry flag is on if there is an error 
jc @@error
mov [filehandle],ax 
jmp @@ebd_func

@@error:
mov [error1],1
@@ebd_func:
ret 
endp Open_File


;-------------------------------------------------------------------------------------------
;Header()-Reads the header. Header is 54 bytes
;Input: file handle
;Output: Header in array
;------------------------------------------------------------------------------------------
proc Header1
mov bx,[filehandle]
mov cx,54
mov dx,offset header 
mov ah,3fh 
int 21h
ret 
endp Header1


;--------------------------------------------------------------------------------------------
;Palette()-Reads color pallete(400h bytes)
;Input: Filehandle
;Output: Colors in array 
;--------------------------------------------------------------------------------------------
proc Palette
mov cx,400h 
mov dx,offset pallete 
mov ah,3fh 
int 21h 
ret 
endp Palette 


;----------------------------------------------------------------------------------------------
;Video-Copies pallete to video memory. Starts in port 3c8h
;Input:Pallete colors 
;Output:None 
;----------------------------------------------------------------------------------------------
proc video 
mov cx,256 
mov dx,3c8h 
mov al,0
mov di,offset pallete
out dx,al
inc dx 

@@loop:
mov al,[di+2]
shr al,2 
out dx,al 

mov al,[di+1]
shr al,2 
out dx,al 

mov al,[di]
shr al,2 
out dx,al 

add di,4
loop @@loop
ret 
endp video 


;----------------------------------------------------------------------------------------------------
;Print()-Displays picture on screen
;Input:None 
;Output:None 
;----------------------------------------------------------------------------------------------------
proc Print
mov cx,200 
mov ax,0a000h
mov es,ax 

@@loop:
 push cx 
mov di,cx
shl cx,6 
shl di,8 
add di,cx 

mov cx,320 
mov dx,offset line
mov ah,3fh 
int 21h 

cld 
mov cx,320 
mov si,offset Line 
rep movsb 
pop cx 
dec cx 
cmp cx,0 
jne @@loop 

ret 
endp Print 


;----------------------------------------------------------------------------------------
;Close_File()-Closes file 
;Input:File Handle 
;Output: None 
;-----------------------------------------------------------------------------------------
Proc Close_File
mov bx,[filehandle]
mov ah,3eh 
int 21h 
ret 
endp Close_File

;--------------------------------------------------------------------------------------------
;Get_Key_Press()- Checks if any key has been pressed down 
;Input: None
;Output: If there is a key waiting to be used, it will be put in al,ah will contain BIOS and zero flag will be turned off 
;        Otherwise zero flag will be turned on.
;--------------------------------------------------------------------------------------------
proc Get_Key_Press
mov ah,1 
int 16h
jnz @@restofprog 
jmp @@end_func

@@restofprog:
mov ah,0
int 16h 
@@end_func:
ret 
endp Get_Key_Press


;--------------------------------------------------------------------------------------------------------
;Case_Insensitive()- Makes key pressed lower case so it dosnt matter if key pressed is lower or upper 
;Input: al-ascii code
;Output: al-ascii code 
;--------------------------------------------------------------------------------------------------------
proc Case_Insensitive
cmp al,"Z"
ja @@end_func 
cmp al,"A"
jb @@end_func
add al,32 
@@end_func:
ret
endp Case_Insensitive


;------------------------------------------------------------------------------
;Terminate()-Terminates the program and changes mode back to text mode 
;Input:None
;Output:None 
;------------------------------------------------------------------------------ 
proc Terminate
push ax 
mov ah,0 ;Goes back into text mode 
mov al,3 
int 10h 
pop ax 
ret  
endp Terminate


;-----------------------------------------------------------------------------------------------------
;Mouse()-Gets mouses position and checks if it has been clicked or being held down
;Input:None
;Output: Cx-Mouses x position 
;        Dx-Mouses y postion
;        Bx-1 if left mouse button is down,2 if right mouse button and 3 if both are down.
;-----------------------------------------------------------------------------------------------------
proc Mouse
push ax 
mov ax,3 
int 33h 
shr cx,1 
pop ax 
ret 
endp Mouse


;-----------------------------------------------------------------------------------------------------
;Second_Pause:Waits a second 
;Input:None
;Output:None 
;-----------------------------------------------------------------------------------------------------
proc Second_Pause
push_regs <ax,cx,dx,si>

	 mov ah,86h 
	 mov dx ,4240h 
     mov cx,0fh 
     int 15h
	
pop_regs <si,dx,cx,ax>
ret 
endp Second_Pause


;------------------------------------------------------------------------------ 
;Set_Pixel()-Draws a colored pixel at a given cooridinates
;Input: [color]-Pixel color  
;       Cx-X cooridinate 
;       Dx-y coordinate 
;Output:None 
;-------------------------------------------------------------------------------
proc Set_Pixel
push_regs <ax,bx,cx,dx,si,di>
;Used for printing straight to VGA memory 
push 0a000h 
pop es 
;x+y*320 
mov si,cx
mov ax,dx 
mov di,ax 
shl ax,8 
shl di,6

mov cl,[color]
add si,di 
add si,ax 
mov[es:si],cl


pop_regs <di,si,dx,cx,bx,ax>
ret 
endp Set_Pixel


;------------------------------------------------------------------------------------------------------
;Pencil():Changes color of pixel wherever mouse is held down
;Input:[color]- color wanted changed to 
;Output:None 
;-------------------------------------------------------------------------------------------------------
proc Pencil
push_regs <ax,bx,cx,dx>
 
@@continueloop:
call Mouse
cmp bx,1 
jne @@endloop

;Border check 
cmp dx,174 
ja @@endloop
cmp cx,28 
jb @@endloop
cmp dx,23 
jb @@endloop
cmp cx,319 
ja @@endloop

mov [point2X],cx 
mov [point2y],dx
 
call DrawLine

mov [point1X],cx 
mov [point1Y],dx 
jmp @@continueloop

@@endloop:
pop_regs <dx,cx,bx,ax>
ret
endp Pencil 


;--------------------------------------------------------------------
;Eraser()-Changes whereever mouses left button is down to white pixel 
;Input:None 
;Output:None 
;-------------------------------------------------------------------
proc eraser
push_regs <ax,bx,cx,dx>

mov ch,0 
mov cl,[color]
push cx
 
mov [color],255 

@@eraserloop:
call Mouse
cmp bx,0 
je @@end_func
cmp dx,174 
ja @@end_func
cmp cx,28 
jb @@end_func
cmp dx,23 
jb @@end_func
cmp cx,319 
ja @@end_func
call Hide_Mouse_Pointer
call set_pixel

inc cx 
call set_pixel

dec dx
call set_pixel

dec cx
call set_pixel

dec cx 
call set_pixel

inc dx 
call set_pixel

inc dx 
call set_pixel

inc cx 
call set_pixel

inc cx 
call set_pixel
call Show_Mouse_Pointer
 
jmp @@eraserloop

@@end_func:
pop cx 
pop_regs <dx,cx,bx,ax> 
ret 
endp Eraser


;----------------------------------------------------------------------------------
;Draw_Square-User drags mouse from one co-ordinate to another and it draws a square
;Input:First postions coordinates
;Output:None
;---------------------------------------------------------------------------------
proc Draw_Square
push_regs <ax,bx,cx,dx>
;First coordinates 
mov [Point1x],cx 
mov [Point1y],dx 
;Waits for mouse releaser
@@loop1:
call Mouse 
cmp bx,1 
je @@loop1 

cmp dx,174 
ja @@passage

cmp cx,28 
jb @@passage

cmp cx,318
jae @@passage 

cmp dx,23 
jbe @@passage 

continue:
mov [Point2x],cx 
mov [Point2y],dx 
 
call Hide_Mouse_Pointer

cmp cx,[Point1x]
jae normal

xchg cx,[Point1x]
mov [Point2x],cx 

normal:
cmp dx,[Point1y]
jae print_the_square

xchg dx,[Point1y]
mov [point2y],dx

print_the_square:
mov cx,[Point1x]
mov dx,[point1Y]
jmp Left_loop

@@passage:
jmp @@end_func

Left_loop:
call Set_Pixel
inc dx 
cmp dx,[Point2y]
jbe Left_loop

bot_loop:
call Set_Pixel
inc cx 
cmp cx,[Point2x]
jbe bot_loop
call Set_Pixel
inc cx 

Right_Loop:
call Set_Pixel
dec dx 
cmp dx,[Point1y]
jae Right_Loop

top_loop:
call Set_Pixel
dec cx 
cmp cx,[Point1x]
jae top_loop

call Show_Mouse_Pointer
 
@@end_func:
pop_regs <dx,cx,bx,ax>
ret
endp Draw_Square



;----------------------------------------------------------------------------------
;Get_Color:Gets pixel color 
;Input: Cx-x coordinate 
;       Dx-y coordinate
;  
; Output:[Color]-Color that was pressed 
;----------------------------------------------------------------------------------
proc Get_Color1
push_regs <ax,bx,dx,si,di,es>
push 0a000h 
pop es 

mov si,cx
mov ax,dx 
mov di,ax 
shl ax,8 
shl di,6


add si,di 
add si,ax 
mov cl,[es:si]
 
pop_regs <es,di,si,dx,bx,ax>
ret
endp Get_Color1


;------------------------------------------------------------------------------------
;DrawLine-Draws line between 2 co-ordinates
;Bressenham Line Algorithm-Graphical Line Drawing Algorithm which chooeses which pixel to place point. 
;Input:2 points to draw between -([point1x],[point1Y]),(cx,dx)
;Output:None 
;------------------------------------------------------------------------------------
proc DrawLine
push_regs <ax,bx,cx,dx>

    cmp cx,[Point1x]
	ja @@normal 
	xchg cx,[Point1x];Want x1 to always be the smaller x 
	xchg dx,[Point1y]

@@normal:
	mov [point2X],cx 
	mov [point2y],dx
	;Checks if the y of both points is the same 
    cmp cx,[point1x]
	je Draw_Verticalpassa

;Finding Deltay and Deltax 
sub cx,[point1X];x2-x1 
mov [deltax],cx
 
mov bx,dx 
sub bx,[point1Y];y2-y1 
mov [deltay],bx 
 
mov [downup],1 
;Checks if slope is negative 
test bx,bx 
jns @@normalthing
mov [downup],2 
neg [deltay]

@@normalthing:
mov ax,[deltax];deltax*2  
mov dx,0 
mov cx,2 
mul cx 
mov [delta2x],ax 

mov ax,[deltay];d=2*deltay-dx 
mov dx,0 
mov cx,2 
mul cx 
mov [delta2y],ax 

mov ax,[deltay]
mov dx,0 
mov bx,[deltax];m=deltay/deltax 
div bx  
mov [slope],ax

cmp [slope],1 
jg octant2
 
call Hide_Mouse_Pointer
jmp Octant1

Draw_Verticalpassa:
jmp Draw_Vertical

Octant1:
;Octant1...If the slope is between -1 and 1 
mov ax,[delta2y];d=2deltay-deltax 
sub ax,[deltax]
mov [d],ax 

mov cx,[point1X]
mov dx,[point1y]
call Set_Pixel;Sets pixel at first point 

@@loop: 
cmp cx,[point2X];If x1=x2,we have drawn all points 
je exitp 

inc cx 
mov ax,[d]
;If d is negative,jump to negative section 
test ax,ax 
js no_move
;Checks if slope is positive or negative,if negative dec dx. Otherwise inc dx 
cmp [downup],1 
je up
dec dx 
jmp @@print
up:
inc dx

@@print: 
    ;Set_Pixel at the new point (x+1,y+1)
	call Set_Pixel
	;d=2deltay-2deltax+d 
	mov bx,[delta2y]
	sub bx,[delta2x]
	add [d],bx 
	jmp @@loop

no_move:
    ;Sets point at (x+1,y)
	call Set_Pixel
	;d=d+2deltay
	mov bx,[delta2y]
	add [d],bx 
	jmp @@loop

exitp:
	jmp @@endprog 

Octant2:
	;Octant2... If slope is between 1 and infinity or -1 and infinity
	;d=2deltax-deltay  
	mov ax,[delta2x]
	sub ax,[deltay]
	mov [d],ax 

	mov cx,[point1X]
	mov dx,[point1Y]
	;Sets pixel at first point 
	call Set_Pixel

@@loop_octant:
	;As soon as both y values are equal,the line is done drawing 
	cmp dx,[point2y]
	je @@endprog
    ;Checks if slope is negative or positive 
	cmp [downup],1 
	jne @@down
	;If positive,inc the y value  
	inc dx 
	jmp @@check
	;If negative,dec the y value 
	@@down:
	dec dx 

@@check :
;Checks if d is negative 
	mov ax,[d]
	test ax,ax 
	js negative_num
;Sets pixel at point (x+1,y+1)
inc cx
call Set_Pixel
;d=d+2deltax-2deltay 
mov ax,[delta2x]
sub ax,[delta2y]
add [d],ax  
jmp @@loop_octant

negative_num:
;Sets pixel at (y+1,x)
call Set_Pixel
;d=d+2deltax 
mov ax,[delta2x]
add [d],ax 
jmp @@loop_octant

	Draw_Vertical:
	cmp dx,[Point1y]
	jb Draw_It
	
	xchg dx,[Point1y]
	Draw_it:
    call Set_Pixel
	inc dx 
	cmp dx,[Point1y]
	jne Draw_Vertical
	
@@endprog:
call Show_Mouse_Pointer
pop_regs <dx,cx,bx,ax>
ret
downup dw ? 
d dw ?
slope dw ?   
deltax dw ? 
deltay dw ?
delta2x dw ? 
delta2y dw ?  
endp DrawLine 


;-------------------------------------------------------------------------------
;Bucket_Fill()-Changes color of all touching similar colors to the color chosen
;Input: Mouse click
;       old color  -ah
;       new color- [color]
;       cx-location to be filled x 
;       dx- location to be filled y
;       Color    
;Output:None 
;-------------------------------------------------------------------------------
proc Bucket_Fill1
push_regs <ax,bx,si>
;Si=counter for stack 
mov si,0 

@@Start_Of_Func:
;Boundary check
cmp dx,172  
ja @@check_recursion

cmp cx,28 
jb @@check_recursion

cmp dx,23 
jb @@check_recursion

cmp cx,319 
ja @@check_recursion

;get color of current pixel(x-cx y-dx )
push cx 
call Get_Color1
mov al,cl 
pop cx 

;Compare color of current pixel to oldcolor
cmp al,ah 
;If they are not equal,ret. 
jne @@check_recursion
;Change pixel color 
call Set_Pixel

;Bucket fill (x+1,y) Section 0
inc cx 
mov bl,0 
call Bucket_Fill_Put_Stack
inc si  
jmp @@Start_Of_Func

Section_0:
;Bucket fill (x,y-1) Section 1 
mov bl,1 
call Bucket_Fill_Put_Stack
dec cx 
dec dx
inc si  
jmp @@Start_Of_Func

Section_1:
;Bucket fill (x-1,y)
dec cx 
inc dx 
mov bl,2 
call Bucket_Fill_Put_Stack
inc si 
jmp @@Start_Of_Func

Section_2:
;Bucket fill (x,y+1)
inc cx 
inc dx 
mov bl,3 
call Bucket_Fill_Put_Stack
inc si  
jmp @@Start_Of_Func

Section_3:
;Restore dx to its starting value 
dec dx 
 
@@check_recursion:
cmp si,0 
je @@end_of_func

dec si 
call Bucket_Fill_Get_Stack
cmp bl,0 
je Section_0 

cmp bl,01 
je Section_1

cmp bl,02
je Section_2

cmp bl,3
je Section_3

@@end_of_func:
pop_regs <si,bx,ax>
ret 
Overflow db "Stack_Overflow",0 
endp Bucket_Fill1


;--------------------------------------------------------------------------------------
;Bucket_Fill_Put_Stack()-Given a counter,put given value into the corresponding position into stack
;Input: si-stack counter 
;       bl- value to place in stack  
;Output: None 
;--------------------------------------------------------------------------------------
proc Bucket_Fill_Put_Stack
push si
push dx 
push bx
push cx   
;SI will point to the byte in stack_bucket value will be placed in.
;DI  will point to the 2 bits in the byte to place value.
mov di,si 
;DI will now hold the stack counter%4. Using the logic expression AND with 3 in binary and di,we check the last 2 bits in di. If one of them is lit,or both, it means
;that the number isnt divisible by four and places the amount of the lit bits into di.
and di,11b
;
mov bh,[mask_array+di]
;The moduler value should be doubled due to the fact that each value is 2 bits  
shl di,1 
;The value is being shifted to the calculated position 
mov cx,di 
shl bl,cl 
;
shr si,2   
;Creates mask 
and [stack_bucket+si],bh
;Puts value into position  
or [stack_bucket+si],bl
pop cx  
pop bx 
pop dx 
pop si  
ret 
mask_array db 0fch,0f3h,0cfh,3fh 
endp Bucket_Fill_Put_Stack


;-------------------------------------------------------------------------------------------
;Bucket_Fill_Get_Stack()-Given a counter,retrieve value from stack counters' position 
;Input:si-Stack counter  
;Ouput:bl-value of stack at stack counters position 
;--------------------------------------------------------------------------------------------
proc Bucket_Fill_Get_Stack
push si 
push di 
push cx 
mov di,si 

and di,11b

shl di,1  

shr si,2 
mov bl,[stack_bucket+si] 
mov cx,di 
shr bl,cl 
and bl,11b

pop cx  
pop di 
pop si 
ret 
endp Bucket_Fill_Get_Stack


;-----------------------------------------------------------------------------------------
;Save_Picture()-Saves current screen into a file 
;Input- [opefile]=file name 
;Output:None 
;-----------------------------------------------------------------------------------------
Proc Save_Pic 
push_regs <ax,bx,cx,dx,si>

mov dx,offset draw
call Open_File 
call Header1 
call Palette
call Close_File

mov dx,offset openfile
call Open_File
 
mov bx,[filehandle]
mov cx,54   
mov dx,offset Header
mov ah,40h 
int 21h
 
mov dx,offset Pallete 
mov cx,1024 
mov ah,40h
int 21h


mov dx,200  
mov cx,0 
mov si,0 
lea si,[line]

@@Loop:
push cx 

call Get_Color1

mov [Line+si],cl 
inc si 
pop cx 
inc cx
 
cmp cx,319  
jbe @@Loop

push dx
 
mov dx,offset Line 
mov cx,320 
mov bx,[filehandle]
mov ah,40h 
int 21h
 
pop dx
 
dec dx 
mov cx,0 
mov si,0
 
cmp dx,0 
jge @@Loop

call Close_File
 
pop_regs <si,dx,cx,bx,ax>
ret
endp Save_Pic

;-------------------------------------------------------------------------
;Open_Pic()-Opens Open_Pic Menu 
;Input:None
;Output:None
;-------------------------------------------------------------------------
proc Open_Pic
push_regs <ax,bx,cx,dx,si>
text1:
   mov ah,0
	mov al,0 
	int 10h
	
    mov [exit],0 	
	lea si,[prompty]
	call Print_Str
	call New_Line
	
	lea si,[prompt2]
	call Print_Str
	call New_Line
	
	lea si,[prompt3]
	call Print_Str
	call New_Line
	
	mov cx,15 
	lea si,[openfile]
	call Scan_Str
	
	mov ah,0 ;Sets graphic mode 
    mov al,13h
    int 10h
	
		
	mov si,0 
	cmp [openfile+si],'q'
	jne @@no_exit1
    inc si 
    cmp [openfile+si],0 
    jne @@no_exit1
    mov [exit],1
    jmp filefound1 	
	
	@@no_exit1:
	mov dx,offset openfile 
	call BmpFile
	
	cmp [error1],1 
	jne filefound1
	
	lea si,[no_file]
	mov ah,0
	mov al,0 
	int 10h
	
	call Print_Str
	call New_Line
	call Second_Pause
	call Second_Pause
	
	mov si,0 
	
	@@loop2:
	mov al,[openfile+si]
	cmp al,0 
	je text1
	mov [openfile+si],0 
	jmp @@loop2
	
filefound1:
    call Show_Mouse_Pointer
	pop_regs <si,dx,cx,bx,ax>
ret 
endp 
;-------------------------------------------------------
;Current_Save:Moves into openfile current.bmp 
;Input:None
;OutputL:None 
;-------------------------------------------------------
proc Current_Save
		mov si,0 
		@@currentloop2:
	mov al,[current+si]
	cmp al,0 
	je @@Save_current2 
	mov [openfile+si],al
    inc si 
    jmp @@currentloop2
	
	@@save_current2: 
ret 
endp 


;-----------------------------------------------------------
;Show_Mouse_Pointer()-Displays mouse pointer on screen 
;Input: None 
;Output:None 
;-----------------------------------------------------------
proc Show_Mouse_Pointer 
push ax 
mov ax,1 
int 33h 
pop ax 
ret 
endp Show_Mouse_Pointer 


;-----------------------------------------------------------
;Hide_Mouse_Pointer()-Hides mouse pointer for screen 
;Input:None 
;Output: None 
;----------------------------------------------------------
proc Hide_Mouse_Pointer
push ax 
mov ax,2 
int 33h 
pop ax 
ret 
endp Hide_Mouse_Pointer
include "c:\gvahim\gvahim.asm"
end ENTRY
