.model tiny
.code
    org 100h
start: jmp real_start
    
    ; place your variables and/or procedures here.
	; Constants
	daynumtxt db "01020304050607080910111213141516171819202122232425262728293031" ; to display day nums
	yeartxt db "0123456789" ;to display year
	instruct db  "Press d:next month a:previous month e:exit " ; to display instructions
	instruct2 db "   March 2020 to January 2024 Calendar     "
	;instruct2 db "      w:next year  s:previous year   e:exit"
	namedays db "Su   Mo   Tu   We   Th   Fr   Sa   Su" ; to print the name of the days of the week
	; to display months
	jantxt db "January"
	febtxt db "February"
	marchtxt db "March"
	apriltxt db "April"
	maytxt db "May"
	junetxt db "June"
	julytxt db "July"
	augtxt db "August"
	septxt db "September"
	octtxt db "October"
	novtxt db "November"
	dectxt db "December"
	save_screen dw 4000 dup(?)
    
    startofmonth dw 3 ; 0 for Su, 1 for Mo, ..., 6 for Sa
    currmonth db 12 ; current month displayed
	yr dw 1 ; last digit of the current year, default value represents 2021
    days dw 31 ; num of days in the month

real_start:

    ; BEGIN BODY

    mov ah,01h
	mov cx,2607h ;hide our cursor
	int 10h

    mov ax,0B800h
    mov es,ax ; ES=>video!
    call intialize
    call background
    sub bx,bx ; bx=0
    call outcorner
    mov bx,2
    call horiborder
    mov bx,160
    call vertiborder

    mov si,844
    mov di,914
    sub bx,bx ; bx=0
    mov byte ptr es:[si],218 ; upper left corner of calendar
    mov byte ptr es:[si+1],71h
    mov byte ptr es:[si+70],191 ; upper right corner of calendar
    mov byte ptr es:[si+71],71h
    mov byte ptr es:[si+1920],192 ; lower left corner of calendar
    mov byte ptr es:[si+1921],71h
    mov byte ptr es:[si+1990],217 ; lower right corner of calendar
    mov byte ptr es:[si+1991],71h
    add si,2
    call topbotcalborder

    mov si,1164
    mov di,1234
    sub bx,bx ; bx=0
    sub dx,dx ; dx=0
    call leftrowcalborder
    sub dx,dx ; dx=0

    ; temp calendar entries
    mov si,1004
	mov di,1074
	sub bx,bx ; bx=0
    call tempentries

    ; name of the days/year
    add si,4
    add di,4
    call yrdayname

    ; display instructions
    sub bx,bx ; bx=0
	mov si,3084
    call instructions

    ; display current month
    sub bx,bx ; bx=0	
	mov si,382
    jmp decmonth
    
    jmp numdays

    jmp key

intialize:
	mov cx,4000
	mov ax,0B800h
	mov es,ax ; ES=>video!
	mov ax,7520h
	sub bx,bx ; bx=0
    ret

background:
    mov es:[bx],ax
	add bx,2
	loop background
    ret

outcorner:
    mov byte ptr es:[bx],201 ; upper left corner
	mov byte ptr es:[bx+1],70h 
    mov byte ptr es:[bx+158],187 ; upper right corner
	mov byte ptr es:[bx+159],70h
	mov byte ptr es:[bx+3840],200 ; lower left corner
	mov byte ptr es:[bx+3841],70h
    mov byte ptr es:[bx+3998],188 ; lower right corner
	mov byte ptr es:[bx+3999],70h
    ret

horiborder:
    mov byte ptr es:[bx],205
    mov byte ptr es:[bx+1],70h
    mov byte ptr es:[bx+3840],205
    mov byte ptr es:[bx+3841],70h
    add bx,2
    cmp bx, 158
    jne horiborder
    ret

vertiborder:
    mov byte ptr es:[bx],186
    mov byte ptr es:[bx+1],70h
    mov byte ptr es:[bx+158],186
    mov byte ptr es:[bx+159],70h
    add bx,160
    cmp bx, 3840
    jne vertiborder
    ret

topbotcalborder:
    inc bx
    cmp bx,5
    je topbotinnercalborder
    mov byte ptr es:[si],196
    mov byte ptr es:[si+1],71h
    mov byte ptr es:[si+1920],196
    mov byte ptr es:[si+1921],71h
    add si,2
    cmp si,di
    jne topbotcalborder
    ret

topbotinnercalborder:
    mov byte ptr es:[si],194
    mov byte ptr es:[si+1],71h
    mov byte ptr es:[si+1920],193
    mov byte ptr es:[si+1921],71h
    add si,2
    sub bx,bx ; bx=0
    jmp topbotcalborder

leftrowcalborder:
    mov byte ptr es:[si],195
    mov byte ptr es:[si+1],71h
    add si,2
rowcalborder:
    inc bx
    cmp bx,5
    je innerrowcalborder
    mov byte ptr es:[si],196
    mov byte ptr es:[si+1],71h
    add si,2
    cmp si,di
    jne rowcalborder
    mov byte ptr es:[si],180 ; rightmost row bar of calendar
    mov byte ptr es:[si+1],71h
    sub si,70
	add si,320
	add di,320
    sub bx,bx ; bx=0
    inc dx
    cmp dx,5
    jne leftrowcalborder
    ret

innerrowcalborder:
    mov byte ptr es:[si],197
    mov byte ptr es:[si+1],71h
    add si,2
    sub bx,bx ; bx=0
    jmp rowcalborder

tempentries:
    mov byte ptr es:[si],179	; left border
    mov byte ptr es:[si+1],71h
    mov byte ptr es:[si+4],'_'
	mov byte ptr es:[si+5],70h
	mov byte ptr es:[si+6],'_'
	mov byte ptr es:[si+7],70h
	add si,10
	cmp si,di
	jne tempentries
    mov byte ptr es:[si],179 ; rightmost bar of calendar
    mov byte ptr es:[si+1],71h
	sub si,70
	add si,320
	add di,320
	inc bx
	cmp bx,6
	jne tempentries	
	mov si,684
	sub bx,bx 
    ret

yrdayname: 
    ; printing out names of days
    mov al,cs:namedays[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],71h
	add si,2
	inc bx
	cmp bx,33
	jne yrdayname
	sub bx,bx ; bx=0
    ; default year '2021'
	add bx,2 ; 2
	mov si,406
	mov al,cs:yeartxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	sub bx,bx
	add bx,0 ; 0
	mov al,cs:yeartxt[bx]
	mov es:[si+2],ax
	mov byte ptr es:[si+3],70h
	sub bx,bx
	add bx,2 ; 2
	mov al,cs:yeartxt[bx]
	mov es:[si+4],ax
	mov byte ptr es:[si+5],70h
	sub bx,bx
	add bx,yr ; last digit of year
	mov al,cs:yeartxt[bx]
	mov es:[si+6],ax
	mov byte ptr es:[si+7],70h
    ret

instructions: 
    mov al,cs:instruct[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],74h
	mov al,cs:instruct2[bx]
	mov es:[si+320],ax
	mov byte ptr es:[si+321],70h
	inc bx
	add si,2
	cmp bx,43
	jne instructions
    ret

janmonth:
    mov currmonth,1
    mov al,cs:jantxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,7
	jne janmonth
    mov ax,7520h
    mov bx,si
    mov es:[bx],ax
	jmp numdays

febmonth:
    mov currmonth,2
    mov al,cs:febtxt[bx]
    mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,8
	jne febmonth
    jmp numdays

marmonth:
    mov currmonth,3
    mov al,cs:marchtxt[bx] 
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,5
	jne marmonth
    mov ax,7520h
    mov bx,si
    mov es:[bx],ax
    mov es:[bx+2],ax
    mov es:[bx+4],ax
	jmp numdays

aprmonth:
    mov currmonth,4
    mov al,cs:apriltxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,5
	jne aprmonth
	jmp numdays

maymonth:
    mov currmonth,5
    mov al,cs:maytxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,3
	jne maymonth
    mov ax,7520h
    mov bx,si
    mov es:[bx],ax
    mov es:[bx+2],ax
	jmp numdays

junmonth:
    mov currmonth,6
    mov al,cs:junetxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,4
	jne junmonth
	jmp numdays

julmonth:
    mov currmonth,7
    mov al,cs:julytxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,4
	jne julmonth
    mov ax,7520h
    mov bx,si
    mov es:[bx],ax
    mov es:[bx+2],ax
	jmp numdays

augmonth:
    mov currmonth,8
    mov al,cs:augtxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,6
	jne augmonth
    mov ax,7520h
    mov bx,si
    mov es:[bx],ax
    mov es:[bx+2],ax
    mov es:[bx+4],ax
	jmp numdays

sepmonth:
    mov currmonth,9
    mov al,cs:septxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,9
	jne sepmonth
	jmp numdays

octmonth:
    mov currmonth,10
    mov al,cs:octtxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,7
	jne octmonth
    mov ax,7520h
    mov bx,si
    mov es:[bx],ax
    mov es:[bx+2],ax
	jmp numdays

novmonth:
    mov currmonth,11
    mov al,cs:novtxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,8
	jne novmonth
	jmp numdays

decmonth:
    mov currmonth,12
    mov al,cs:dectxt[bx]
	mov es:[si],ax
	mov byte ptr es:[si+1],70h
	inc bx
	add si,2
	cmp bx,8
	jne decmonth
    jmp numdays

numdays:
    cmp currmonth,1
	je days31_
	cmp currmonth,2
	je days28_
	cmp currmonth,3
	je days31_
	cmp currmonth,4
	je days30_
	cmp currmonth,5
	je days31_
	cmp currmonth,6
	je days30_
	cmp currmonth,7
	je days31_
	cmp currmonth,8
	je days31_
	cmp currmonth,9
	je days30_
	cmp currmonth,10
	je days31_
	cmp currmonth,11
	je days30_
	cmp currmonth,12
	je days31_

days28_:
	jmp days28
days29_:
	jmp days29
days30_:
	jmp days30
days31_:
	jmp days31

days28:
    mov days,27
	mov si,1004
	mov di,1074
	sub bx,bx ; bx=0
    call tempentries
    jmp prefilling

days29:
    mov days,28
	mov si,1004
	mov di,1074
	sub bx,bx ; bx=0
    call tempentries
    jmp prefilling

days30:
    mov days,29
	mov si,1004
	mov di,1074
	sub bx,bx ; bx=0
    call tempentries
    jmp prefilling

days31:
    mov days,30
	mov si,1004
	mov di,1074
	sub bx,bx ; bx=0
    call tempentries
    jmp prefilling

prefilling:
    sub bx,bx ; bx=0 used to index string
    sub cx,cx ; cx=0 used to count the days
	sub dx,dx ; dx=0 used to keep track of the start of the next month
    mov si,1008 ; move to first entry of calendar
    mov di,1078
    ; offsets the first day of the month
    cmp startofmonth,0
	je sun
	cmp startofmonth,1
	je mon
	cmp startofmonth,2
	je tue
	cmp startofmonth,3
	je wed
	cmp startofmonth,4
	je thu
	cmp startofmonth,5
	je fri
	cmp startofmonth,6
	je sat

fillmonth:
    mov al,cs:daynumtxt[bx]
	mov es:[si],ax ; first digit
    mov byte ptr es:[si+1],70h
    mov al,cs:daynumtxt[bx+1] ; second digit
    mov es:[si+2],ax
	mov byte ptr es:[si+3],70h
    add bx,2
	inc dx
    inc cx
    cmp cx,days
    jg key1
	add si,10
	cmp si,di
    jne fillmonth
	sub dx,dx
    sub si,70
	add si,320
	add di,320
    jmp fillmonth

key1:
    jmp key

sun:
    mov si,1008
    jmp fillmonth
mon:
    mov si,1018
    jmp fillmonth
tue:
    mov si,1028
    jmp fillmonth
wed:
    mov si,1038
    jmp fillmonth
thu:
    mov si,1048
    jmp fillmonth
fri:
    mov si,1058
    jmp fillmonth
sat:
    mov si,1068
    jmp fillmonth

nextmonth:
    sub bx,bx ; bx=0
	mov startofmonth,dx
	mov si,382
    cmp currmonth,1
	je febmonth1
	cmp currmonth,2
	je marmonth1
	cmp currmonth,3
	je aprmonth1
	cmp currmonth,4
	je maymonth1
	cmp currmonth,5
	je junmonth1
	cmp currmonth,6
	je julmonth1
	cmp currmonth,7
	je augmonth1
	cmp currmonth,8
	je sepmonth1
	cmp currmonth,9
	je octmonth1
	cmp currmonth,10
	je novmonth1
	cmp currmonth,11
	je decmonth1
	cmp currmonth,12
	je finalmonthofyr

finalmonthofyr:
	call incyear
	jmp janmonth1

janmonth1:
    jmp janmonth
febmonth1:
    jmp febmonth
marmonth1:
    jmp marmonth
aprmonth1:
    jmp aprmonth
maymonth1:
    jmp maymonth
junmonth1:
    jmp junmonth
julmonth1:
    jmp julmonth
augmonth1:
    jmp augmonth
sepmonth1:
    jmp sepmonth
octmonth1:
    jmp octmonth
novmonth1:
    jmp novmonth
decmonth1:
    jmp decmonth

prevmonth:
    sub bx,bx ; bx=0
	mov si,382
    cmp currmonth,1
	je firstmonthofyr
	cmp currmonth,2
	je prevstart31daymonth0
	cmp currmonth,3
	je febmonth1
	cmp currmonth,4
	je prevstart31daymonth0
	cmp currmonth,5
	je prevstart30daymonth1
	cmp currmonth,6
	je prevstart31daymonth0
	cmp currmonth,7
	je prevstart30daymonth1
	cmp currmonth,8
	je prevstart31daymonth0
	cmp currmonth,9
	je prevstart31daymonth0
	cmp currmonth,10
	je prevstart30daymonth1
	cmp currmonth,11
	je prevstart31daymonth0
	cmp currmonth,12
	je prevstart30daymonth1

firstmonthofyr:
	call decyear
	jmp prevstart31daymonth0

prevstart31daymonth0:
	jmp prevstart31daymonth1

prevstart30daymonth1: ; if the previous month is 30 days
	cmp startofmonth,2
	jl prevstart30daymonth2
	sub startofmonth,2
	cmp currmonth,1
	je decmonth2
	cmp currmonth,2
	je janmonth2
	cmp currmonth,3
	je febmonth2
	cmp currmonth,4
	je marmonth2
	cmp currmonth,5
	je aprmonth2
	cmp currmonth,6
	je maymonth2
	cmp currmonth,7
	je junmonth2
	cmp currmonth,8
	je julmonth2
	cmp currmonth,9
	je augmonth2
	cmp currmonth,10
	je sepmonth2
	cmp currmonth,11
	je octmonth2
	cmp currmonth,12
	je novmonth2

janmonth2:
    jmp janmonth
febmonth2:
    jmp febmonth
marmonth2:
    jmp marmonth
aprmonth2:
    jmp aprmonth
maymonth2:
    jmp maymonth
junmonth2:
    jmp junmonth
julmonth2:
    jmp julmonth
augmonth2:
    jmp augmonth
sepmonth2:
    jmp sepmonth
octmonth2:
    jmp octmonth
novmonth2:
    jmp novmonth
decmonth2:
    jmp decmonth

prevstart30daymonth2:
	add startofmonth,5
	cmp currmonth,1
	je decmonth2
	cmp currmonth,2
	je janmonth2
	cmp currmonth,3
	je febmonth2
	cmp currmonth,4
	je marmonth2
	cmp currmonth,5
	je aprmonth2
	cmp currmonth,6
	je maymonth2
	cmp currmonth,7
	je junmonth2
	cmp currmonth,8
	je julmonth2
	cmp currmonth,9
	je augmonth2
	cmp currmonth,10
	je sepmonth2
	cmp currmonth,11
	je octmonth2
	cmp currmonth,12
	je novmonth2

prevstart31daymonth1: ; if the previous month is 31 days
	cmp startofmonth,3
	jl prevstart31daymonth2
	sub startofmonth,3
	cmp currmonth,1
	je decmonth3
	cmp currmonth,2
	je janmonth3
	cmp currmonth,3
	je febmonth3
	cmp currmonth,4
	je marmonth3
	cmp currmonth,5
	je aprmonth3
	cmp currmonth,6
	je maymonth3
	cmp currmonth,7
	je junmonth3
	cmp currmonth,8
	je julmonth3
	cmp currmonth,9
	je augmonth3
	cmp currmonth,10
	je sepmonth3
	cmp currmonth,11
	je octmonth3
	cmp currmonth,12
	je novmonth3

janmonth3:
    jmp janmonth
febmonth3:
    jmp febmonth
marmonth3:
    jmp marmonth
aprmonth3:
    jmp aprmonth
maymonth3:
    jmp maymonth
junmonth3:
    jmp junmonth
julmonth3:
    jmp julmonth
augmonth3:
    jmp augmonth
sepmonth3:
    jmp sepmonth
octmonth3:
    jmp octmonth
novmonth3:
    jmp novmonth
decmonth3:
    jmp decmonth

prevstart31daymonth2:
	add startofmonth,4
	cmp currmonth,1
	je decmonth3
	cmp currmonth,2
	je janmonth3
	cmp currmonth,3
	je febmonth3
	cmp currmonth,4
	je marmonth3
	cmp currmonth,5
	je aprmonth3
	cmp currmonth,6
	je maymonth3
	cmp currmonth,7
	je junmonth3
	cmp currmonth,8
	je julmonth3
	cmp currmonth,9
	je augmonth3
	cmp currmonth,10
	je sepmonth3
	cmp currmonth,11
	je octmonth3
	cmp currmonth,12
	je novmonth3

incyear: ; increment year
	cmp yr,9
	je key
	mov si,406
	sub bx,bx ; bx=0
	add yr,1
	add bx,yr
	mov al,cs:yeartxt[bx]
	mov es:[si+6],ax
	mov byte ptr es:[si+7],70h
	sub bx,bx ; bx=0	
	mov si,382
	ret

prevmonth1:
	jmp prevmonth

decyear: ; decrement year
	cmp yr,0
	je key
	mov si,406
	sub bx,bx ; bx=0
	sub yr,1
	add bx,yr
	mov al,cs:yeartxt[bx]
	mov es:[si+6],ax
	mov byte ptr es:[si+7],70h
	sub bx,bx ; bx=0	
	mov si,382
	ret

; waiting for key
key:
    mov ah,1
    int 16h
    jz key

    mov ah,00h
    int 16h
    cmp al,100 ; d, next month
    je nextmonth1
    cmp al,97 ; a, prev month
    je prevmonth1
    ;cmp al,119 ; w, next year
	;je nextyear
    ;cmp al,115 ; s, prev year
    cmp al,101 ; e, exit
    je clear
    jmp key

nextmonth1:
    jmp nextmonth

;nextyear:
;	mov cx,12
;	jmp nextmonth
;	loop nextyear
;	jmp key

clear:
	mov cx,4000
	mov ax,0B800h
	mov es,ax ; ES=>video!
	mov ax,0520h
	sub bx,bx ; bx=0
exit:
	mov es:[bx],ax
	add bx,2
	loop exit
    mov ah,4ch
    int 21h


    end start