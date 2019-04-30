TITLE Snake.asm
;2019/1/9
;�������i

INCLUDE Irvine32.inc

.DATA

;lable ���ҫŧi����

a WORD 1800 DUP(0)  ; �P��]�w row cloum
tailR BYTE 18d         ; ���D��row  �Ŷ�18d       
tailC BYTE 47d         ; ���D��colum �Ŷ�47d
headR BYTE 13d         ; �D�Y row �Ŷ�13d
headC BYTE 47d         ; �D�Y colum �Ŷ�47d
foodR BYTE 0           ; ��⭹�� row fR1 ����
foodC BYTE 0           ; ��⭹�� colum fC��ñ

tmpR BYTE 0         ; �Ȧsrow �Ȫ�����
tmpC BYTE 0         ; �Ȧscolum�Ȫ�����

Up BYTE 0d          ; �]�w���W����
Lf BYTE 0d          ; �]�w��������
Dn BYTE 0d          ; �]�w���U����
Ri BYTE 0d          ; �]�w���k����

eTail   BYTE    3d  ; ������O�Y�쭹�����ڬO�_�������� 
search  WORD    0d  ; �@���M�����
eGame   BYTE    0d  ; ����ᵲ��������
cScore  DWORD   0d  ; �`����ܼ���

d       BYTE    'w' ; d ����U�@���D��P�_����
newD    BYTE    'w' ; newD ���s���D��D��P�_����
delTime DWORD   100 ; �t�׳]�w100 

menuS   BYTE "��1,Start the Game" ,0     ;�}�l�C������
hitS    BYTE "Game over", 0  ; �C����������
scoreS  BYTE "Score: 0", 0  ;���Ƽ���

myHandle DWORD ?    ; �O�_�פinput�ܼƼ���
numInp   DWORD ?    ;  �Y�쭹�����ܼƽw�ļ��� 
temp BYTE 16 DUP(?) ; �V�O����ŧi16byte �Ȧs�Ŷ� (forINPUT_RECORD) ����
bRead    DWORD ?    ; Ū���Ȧs�Ȫ� �����O irvine��ܤ�����

.CODE
;---------------------------------------------------------------------------------------
main PROC     ;�D�{��

menu:                           ;��� function local �ܼ�
    CALL Randomize              ;�����é� call�Ƶ{��(Randmize)
    CALL Clrscr                 ; irvine ��ƴ��� �M��
    MOV EDX, OFFSET menuS       ; menuS ���X���EDX�Ȧs��
    CALL WriteString            ; irvine ���� �ù����
    
wait1:
	CALL ReadChar               ;irvine ���� Ū���r�� 1�^��  �}�l  
    CMP AL, '1'                 ; 1�����
    JE startG                   ;����}�l�C���e��
	EXIT                        ;���X 

startG:                     ; �C���}�l�]�wfunction  local�ܼ�	
    MOV EAX, 0                  ; �M�żȦs
    MOV EDX, 0                  ; �M�žԦs 
    CALL Clrscr                 ; 
    CALL initSnake              ; �I�sinitSnake �Ƶ{��
  CALL createFood             ; �I�s�����إ� createFood
    CALL startGame              ; �I�sstartGame �Ƶ{��
   CALL Paint                  ; �I�s paint (�W��)�Ƶ{��
  CALL SetTextColor           ; �I�ssettextcolor�Ƶ{��
  
main ENDP      ;�D�{������
;---------------------------------------------------------------------------------------
initSnake PROC USES EBX EDX         ;�Ƶ{���D���l�]�w  13~18 row number �üg�J framebuffer��

    MOV DH, 13      ; �]�w row number to 13
    MOV DL, 47      ; �]�w column number to 47
    MOV BX, 1       ; �Ĥ@�ӳD����q
    CALL saveIndex  ; Ū�i framebuffer
    MOV DH, 14      ; 
    MOV DL, 47      ; 
    MOV BX, 2       ; ��2�ӳD����q
    CALL saveIndex  ;
    MOV DH, 15      ; 
    MOV DL, 47      ; 
    MOV BX, 3       ; ��3�ӳD����q
    CALL saveIndex  ; 
    MOV DH, 16      ; 
    MOV DL, 47      ; 
    MOV BX, 4       ; ��4�ӳD����q
    CALL saveIndex  ;  
    MOV DH, 17     ; 
    MOV DL, 47      ; 
    MOV BX, 5       ; ��4�ӳD����q
    CALL saveIndex  ; �I�s�Ƶ{��  �s�J����
 
 
    MOV DH, 18      ; 
    MOV DL, 47      ; 
    MOV BX, 6       ; ��5�ӳD����q
    CALL saveIndex  ; 
 RET                 ;�^�ǭ�
initSnake ENDP      ;��l�D��Ƶ{������
;---------------------------------------------------------------------------------------
clearMem PROC       ;��ɳ]�w�Ƶ{�� (���Ĳ�I�]�w)

    MOV DH, 0               ;�]�w row DH�Ȧs����0
    MOV BX, 0               ;�]�w��ƼȦs��BX��0

    oLoop:                  ; �� rows �l�{���]�w���
        CMP DH, 24          ; �̤j24 �W�L����                      
        JE endOLoop         ; ���즺�`�l�{��
		CALL saveIndex      ;�I�ssaveindex ����
		INC DH              ;�g�Jrow�Ȧs DH
		JMP oLoop           ;�~��boLoop ������� ��������� 

    iLoop:              ;  ��column�]�w�l�{���̤j��
        CMP DL, 75      ; 
        JE endILoop     ; 
        CALL saveIndex  ;                          
        INC DL          ; 
		JMP iLoop       ;

    endILoop:               ; cloumn iloop���� 
	
	    INC DH              ; �g�Jrow DH�Ȧs
        JMP oLoop           ; ����oloop�~���~��

    endOLoop:               ; row oloop ����
	    INC DL              ; �g�Jrow DH�Ȧs
        JMP iLoop           ; ����iloop�~���~��

clearMem ENDP  ;��ɰƵ{������
;---------------------------------------------------------------------------------------
startGame PROC USES EAX EBX ECX EDX    ; �}�l�����I���{��   �ϥ�eax ebx ecx edx �Ȧs��
     MOV EAX, white + (blue * 16)       ; �C��]�w  ,�ũ��զr (�������code)
     CALL SetTextColor                   ; irvine �C��]�wfuntion����    
     MOV DH, 24                          ; ������ܦ�mrow24
     MOV DL, 0                           ; coulum0
	 CALL GotoXY                         ; irvine �b�D����x��ܦ�m��C���w funtion���� 
     MOV EDX, OFFSET scoreS       
	 CALL WriteString                    ;irvine��ܦb�D����x�\�ണ��

    ;�зǿ�J�]�w masm���� ����x��J�w�İϳ]�w EAX
     INVOKE getStdHandle, STD_INPUT_HANDLE
     MOV myHandle, EAX
	 MOV ECX, 10

    ; �зǿ�J�]�w masm���� �q����x���w�İ� Ū���ƾڳ]�w
    INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
    INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead

    more:                        ;�D�n�]�ʪ��l�{�����

    ; �зǿ�J�]�w masm���� �qMYhandle��Ū�����
     INVOKE GetNumberOfConsoleInputEvents, myHandle, ADDR numInp
   
      MOV ECX, numInp
      CMP ECX, 0                          ; �ˬd�Y�J���ȦsECX�O�_����
      JE done                             ; �p�G�����~��]

    ;�qinputbuffer Ū����� �üȦs��temp��
     INVOKE ReadConsoleInput, myHandle, ADDR temp, 1 , ADDR bRead
  
     MOV DX, WORD PTR temp               ; �T�{�O�_��KEY_EVENT
     CMP DX, 1                           ; �s�JDX (DX ����1)
     JNE SkipEvent                       ; �Y�J�᪺�D�� �n��skipEvent
     MOV DL, BYTE PTR [temp+4]       ; ����Ȧs�Ŷ����� DL
     CMP DL, 0                        ;DL ��0 
     JE SkipEvent                    ;����SKIPEVEN
     MOV DL, BYTE PTR [temp+10]      ; Ū���������� DL
     CMP DL, 1Bh                 ; ��ESC���X  DL�Ȧs�a    (DL=1BH)
     JE quit                     ; ���X (quit)

     CMP d, 'w'                  ; �T�{�ثe�D����V (d="w")
	 JE case1                    ; ��V�����J�� WS ���ܤ�V������
     CMP d, 's'                  ;      (d="s")
     JE case1                    ;   ��V�����J�� WS ���ܤ�V������
     JMP case2                   ; ��V��������CASE2
                                            
      case1:
                    CMP DL, 25h             ; ���}�C��J  (DL=25h)
                    JE case11               ;  ��CASE11
                    CMP DL, 27h             ; �k��}�C��J (DL=27h)
                    JE case12               ;��CASE 12   
                    JMP SkipEvent           ; �p�G�O�W�U�}�C��J ���Χ��ܤ�V  �̼˦bmore�o�^�����
      case11:
                    MOV newD, 'a'       ; �]�w�s��V a  ����
                    JMP SkipEvent
	  case12:
                    MOV newD, 'd'       ; �]�w�s��Vd ���k
                    JMP SkipEvent        ;���^more�j��

      case2:
                    CMP DL, 26h             ; �W�}�C��J (DL=26h)
                    JE case21               ;��case21      
                    CMP DL, 28h             ; �U�}�C��J (DL=28h)
                    JE case22               ;��cace22
                    JMP SkipEvent           ; �Y�����k��J �~��bmore�j��]
                  
	  case21:
                    MOV newD, 'w'       ; �]�w�s��V���W
                    JMP SkipEvent       ;�~����^more�j��] 
      case22:
                    MOV newD, 's'       ; �]�w�s��V���U
                    JMP SkipEvent       ;�~����^more�j��]

    SkipEvent:    ;�~����^more �j�骺 local �ܼ�    
	JMP more                            ; ����more

    done:         ;���ܳD���V�� local �ܼ�
        MOV BL, newD                        ; �s��VnewD �s��JBL�Ȧs                                           
        MOV d, BL                           ;Ū��BL �ܦ��{����V d 
        CALL MoveSnake                      ; �I�s�Ƶ{��  movesnake �i���{�b����V
        MOV EAX, DelTime                    ; ���X�Ȧs�� DelTime
        CALL Delay                          ; ���ʳt�׳]�w  �I�s Delay
        CMP eGame, 1                        ; �������ҳ]�w1  (eGame=1)
        JE quit                             ; ���X�j��
       JMP more                            ; ���^more �j��

    quit:                                  ;���X �Ƶ{��   local �ܼ�
    RET              ;�^��startgame����   
	
startGame ENDP   ;�C���}�l �Ƶ{������
;---------------------------------------------------------------------------------------
MoveSnake PROC USES EBX EDX      ;�D�鲾�ʰƵ{��  �ϥ�EBX EDX

        CMP eTail, 1            ; �h�����L���K ����
        JNE NoETail             ; �p�G�S���Ҥ��n�h�����K ���� noetail
        MOV DH, tailR          ;  ��D��row ���е�DH
        MOV DL, tailC          ;  DL��D��column ���е�DH
        CALL accessIndex    ;  �I�saccessindex �Ƶ{�� ��DH DL����
        DEC BX              ;  ��ȵ�BX ���ͳD�驹�e���U�@�Ӥ��q
        MOV search, BX      ; BX   �ƻsBX���ȵ��U�@�ӳD�骺���q
        MOV BX, 0           ;  BX�� 0 �I�s saveindex �Ƶ{��
        CALL saveIndex      ; ���Ʀs�isaveindex
        CALL GotoXY         ; invrine�@�̴��� �M���D�D�� �A�D���ᨫ�L�� �ù��C�� 
        MOV EAX, white + (black * 16)
        CALL SetTextColor   ;�I�s�Ƶ{�� settextcolor �C��]�w�Ƶ{��
        MOV AL, ' '          ; �ŭ�  ���騫�L�B���W��
        CALL WriteChar       ;invrine ���� ���@�ӳ�W�r���i�зǿ�X
        PUSH EDX            ; ��JEDX�Ȧs��  
        MOV DL, 74
        MOV DH, 23         
        CALL GotoXY          ;invrine�@�̴��� �M���D�D�� �A�D���ᨫ�L�� �ù��C�� 
        POP EDX
        MOV AL, DH          ; Ū�XDH  tail row �� ��AL
        DEC AL              ;    (�W)
        MOV Up, AL          ; ��AL �Ȩ��X�s�Jup
        ADD AL, 2           ;    (�U)
        MOV Dn, AL          ; ��AL �Ȩ��X�s�Jdown
        MOV AL, DL          ; Ū��DL tail column ����AL
        DEC AL              ; (��)
        MOV Lf, AL          ; ��AL�Ȩ��X�� lift
        ADD AL, 2           ; (�k)
        MOV Ri, AL          ; ��AL �Ȩ��X��right
        CMP Dn, 24          ; Down �W�X24 row �d��
        JNE next1           ; �� next 1 �ܼ�   
            MOV Dn, 0       ; 

     next1:
        CMP Ri, 74          ; right�W�X74 �d��(cP������74)
        JNE next2           ;��next 2 �ܼ�
            MOV Ri, 0       ; 
     next2:
        CMP Up, 0           ;up(�W����) > 0 
        JGE next3           ;�� next 3�ܼ� 
            MOV Up, 23      ; 
     next3:
        CMP Lf, 0            ;lift(������) > 0
        JGE next4          
            MOV Lf, 73      
     next4:
        MOV DH, Up          ;  up(�W����)�ȶǵ�DH (row)
        MOV DL, tailC          ;    DL tC(�D��cloum)�ȶǵ� DL (coloum)
        CALL accessIndex    ;   �I�s accessindex �q����ҰƵ{��
        CMP BX, search      ; BX������serch
        JNE melseif1        ;���� melseif �ܼ�
            MOV tailR, DH      ;����tR(�D����DH) 
            JMP mendoff      ;����mendoff����

     melseif1:           ;�U������ 
        MOV DH, Dn          ; 
        CALL accessIndex    ; 
        CMP BX, search      ; BX������serch
        JNE melseif2
        MOV tailR, DH           ; 
        JMP mendoff        ; ���X�j�骺����

     melseif2:           ;��������
        MOV DH, tailR          ; tailR(�D��row��)��DH
        MOV DL, Lf          ; lift(��ecolumn����)�ȵ�DL
        CALL accessIndex    ; �I�saccessindex �Ƶ{�� ��W�����F���J accessindex
        CMP BX, search      
        JNE melse           ;���U�@��melse �k���� 
        MOV tailC, DL      ; tC(�D��colunm)�� ��DL
        JMP mendoff          ;���X�j�骺����

    melse:              ;�k������  
        MOV DL, Ri      ; right (colunm �k)
        MOV tailC, DL      ;tC (�D��cloum)   

    mendoff:             ;���X�j����� 

    NoETail:
        MOV eTail, 1            ;  �]�w�M�����ڼ���
        MOV DH, tailR              ;  �ƻsrow����tR ��DH
        MOV DL, tailC              ; �ƻscolumn����tR ��DL
        MOV tmpR, DH            ; �ƻsDH�Ȧ�tmpR �Ȧs�O���餤
        MOV tmpC, DL            ; �ƻsDL�Ȧ�tmpR �Ȧs�O���餤

    whileTrue:              ; �Y���u �D��L�a�j��
        MOV DH, tmpR        ; ��e temR row���� �s��DH
        MOV DL, tmpC        ; ��e temC colunm���� �s��DL
        CALL accessIndex    ; �I�s accessindex�Ƶ{�� 
        DEC BX              ;
        MOV search, BX      ; BX�U�ӳD����q�ȵ�search
        PUSH EBX            ; ��stack ��J EBX  ��i���X
        ADD BX, 2           ; 
        CALL saveIndex      ;  �I�s�Ƶ{��  �D�� �D����q�N��۰�
        POP EBX
        CMP BX, 0           ; BX 0  �N�O�D�Y0
        JE break            ; ���ܵ����j�����
        MOV AL, DH          ; DH�ȵ�AL
        DEC AL              ; AL row �W����
        MOV Up, AL          ; AL �s��Up(row�W����)
        ADD AL, 2           ; AL �U����
        MOV Dn, AL          ; AL �s��down(row�U����)
        MOV AL, DL          ; 
        DEC AL              ; ��
        MOV Lf, AL          ; ��
        ADD AL, 2           ; �k
        MOV Ri, AL          ; �k
        CMP Dn, 24          ; �W�X24 (�U)
        JNE next21          ;����next21
        MOV Dn, 0       ; �M�����L���ù����

     next21:
       CMP Ri, 74         ; �W�L74  (�̤j75) right������74
       JNE next22         ;����next22
       MOV Ri, 0       ; �M�����L���ù����

     next22:              ;�̤j24
       CMP Up, 0           ;up >= 0
       JGE next23       ;��next23
       MOV Up, 23      ; �M�����L23piexl
	   
	 next23:           ;�M���W�@�Ө��L�����q
       CMP Lf, 0           ; lift >=0
       JGE next24      ;��24    
       MOV Lf, 73     ; �M�����L73 piexl

     next24:               ;      �~���U�@�Ӥ��q���ʼ���
       MOV DH, Up          ; ��up �ȵ� DH(row index)
       MOV DL, tmpC        ; ��colunm���qpixel(�D��) �s�JDL
       CALL accessIndex    ; �I�s�Ƶ{�� ��ȵ�accessindex
       CMP BX, search      ; BX������search
       JNE elseif21        ;��elseif2-1
       MOV tmpR, DH    ; ���ʤU�@����q   DH �ȵ�tmpR
       JMP endif2        ;��endif2   (�~��bwhileture �j��])

     elseif21:         
       MOV DH, Dn          ;  (row pixel��rD) ��DH
       CALL accessIndex    ;  �I�s�Ƶ{�� accessindex �s�J
       CMP BX, search      ; BX������ search  
       JNE elseif22         ;����elseif22 �Ƶ{��
       MOV tmpR, DH    ;  �~��s����m  DH �ȵ�tmpR
       JMP endif2      ;��endif2   (�~��bwhileture �j��])

     elseif22:
        MOV DH, tmpR        ;  DH row pixel �����q��DH
        MOV DL, Lf          ;  colunm pixel �����q��DL
        CALL accessIndex    ; �I�s�Ƶ{�� accessindex �s�J
        CMP BX, search      ;  BX������search  
        JNE else2           ;�� else2 ���k���          
        MOV tmpC, DL    ;  ���k���� DL�ȵ�tmpC ��ܦb�ù��W
		JMP endif2         ;��endif2   (�~��bwhileture �j��])

      else2:
            MOV DL, Ri      ; right ���k�� ��DL
            MOV tmpC, DL    ; DL �� tmpC(�Ȧs���)

      endif2:
        JMP whileTrue       ;�~��bwhileTure �j��]  �Ȩ��Y�I��

    break:                  ;�פ���� ����
      MOV AL, headR              ; hR (�D��'row)�� ��AL
      DEC AL                  ; AL����
      MOV Up, AL              ; AL�Ȧs�Jup(row�W�ȴ��)
      ADD AL, 2               ; AL 2 ���U�@�ӭ�
      MOV Dn, AL              ; AL�Ȧs�Jdown(�D�Urow ���U�[)
      MOV AL, headC              ; hC (�D��clunm)�� ��AL
      DEC AL                  ; column AL����
      MOV Lf, AL              ; AL�Ȧs�Jlift(colum����� ���)
      ADD AL, 2               ;  AL 2 ���U�@�ӭ�
      MOV Ri, AL              ; AL�Ȧs�Jright(colum�k��� �W�[)
      CMP Dn, 24              ; �T�{24 ��� down������24
      JNE next31              ;�W�L24 �� next 31  
      MOV Dn, 0           ; �M��rP

    next31:
      CMP Ri, 74              ; �T�{74��� right������74
      JNE next32              ;�W�L��next32 
      MOV Ri, 0           ; �M��cP

   next32:
    CMP Up, 0               ; up>=0
    JGE next33              ;��next 33
    MOV Up, 23          ; up����23

   next33:
    CMP Lf, 0               ; lift>=0
    JGE next34               ;��next34  
        MOV Lf, 73          ;lift����73

    next34:                 ;�`���W�����L�� ��Ȧs��DH DL
    CMP d, 'w'              ; �W"w" d���O"w"
    JNE elseif3             ;�� elseif3
        MOV AL, Up          ; row �Y��J�s��m up�ȵ�AL
        MOV headR, AL          ; AL �� hR 
        JMP endif3          ;�s�ȵ� DH DL

    elseif3:
    CMP d, 's'              ; �U"s"   d���O"s"
    JNE elseif32            ; �� elseif32 
        MOV AL, Dn          ; 
        MOV headR, AL          ; 
        JMP endif3          ;�s�ȵ� DH DL

    elseif32:
    CMP d, 'a'              ; ��"a"  d���O"a"
    JNE else3
        MOV AL, Lf          ; 
        MOV headC, AL          ; �s�ȵ� DH DL
        JMP endif3

    else3:                  ;�k 
        MOV AL, Ri           
        MOV headC, AL          

    endif3:                 ;�s�� ��DH DL
    MOV DH, headR              ; �srow �Y
    MOV DL, headC              ; �scol�Y
    CALL accessIndex        ; �I�s�Ƶ{�� accessindex ��DH DL �Ȧs�J
    CMP BX, 0               ; BX= 0
    JE NoHit                ; ��nohit
    MOV DH, 24              ; 
    MOV DL, 11              ; 
    CALL GotoXY              ;�@�̨�ƴ���
    CALL WriteString         ;�@�̨�ƴ���
    CALL Delay              ; �@�̨�ƴ��� ���w
    MOV eGame, 1            ; eGame ����1 �C������
    RET                     ; 

 NoHit:                     ; �S�Y�쭹�����ҳ]�w
    MOV BX, 1               ; 
    CALL saveIndex          ; 
    MOV cl, foodC              ; ���� col (cl�O����)
    MOV ch, foodR              ; ���� row (ch�O����)
    CMP cl, DL              ; ��� �D�Y column �M���� column (c1������DL)
    JNE foodNotGobbled      ;��(foodnotgobbled)�S�Y�쭹��
    CMP ch, DH              ; ��� �D�Y row �M���� row    (ch������DH)
    JNE foodNotGobbled      ;��(foodnotgobbled)�S�Y�쭹��
    CALL createFood         ; �����Q�Y  �I�s careatefood�Ƶ{��
    MOV eTail, 0            ;                           
	MOV EAX, white + (black * 16)  ;�]�w�C��
    CALL SetTextColor       ;�@�̴���
    PUSH EDX                ; Push EDX onto stack
    MOV DH, 24              ; ���Ƹ��I�B
    MOV DL, 7               ;���Ƹ��I�B         
    CALL GotoXY             ;�@�̴���
    MOV EAX, cScore         ; ���ƭp��  
    INC EAX
    CALL WriteDec
    MOV cScore, EAX         ; ��s���ƭp��
    POP EDX                 ; Pop EDX off of stack

    foodNotGobbled:         ; �S�Y�쭹������
    CALL GotoXY             ; �@�̴���  
    MOV EAX, blue + (white * 16)
    CALL setTextColor       ;
    MOV AL, ' '             ;
    CALL WriteChar           ;
    MOV DH, 24             ; DH 24  �o�˴N�û����|����
    MOV DL, 74             ; DL 74  �o�˴N�ä�����
    CALL GotoXY
    RET                     
MoveSnake ENDP             ;�D�鲾�ʰƵ{������
;---------------------------------------------------------------------------------------
createFood PROC USES EAX EBX EDX
 redo:                       ; �إ߭���������
    MOV EAX, 20                 ; �]�w20 
    CALL RandomRange            ; range 0 to numRows - 1  �@�̴��� �H����
    MOV DH, AL
    MOV EAX, 60                ; �]�w60
    CALL RandomRange            ; range 0 to numCol - 1 �@�̴��� �H����
    MOV DL, AL
    CALL accessIndex            ; �I�s�Ƶ{�� accessindex
    CMP BX, 0                   ; BX 0�h
    JNE redo                    ;���^ redo
    MOV foodR, DH                  ; �]�w����row��
    MOV foodC, DL                  ; �]�w����col��
    MOV EAX, white + (cyan * 16); �����C��]�w
    CALL setTextColor           ;�@�̴���
    CALL GotoXY                 ; �@�̴���
    MOV AL, ' '                 ; 
    CALL WriteChar               ;�@�̴���
    RET
createFood ENDP
;---------------------------------------------------------------------------------------
accessIndex PROC USES EAX ESI EDX    ;DH  DL ��pixel�^�� framebuffer�A value�� �A�^�Ǩ�BX�Ȧs��  (������) 
    MOV BL, DH      ; DH��row ���ȶǵ� BL
    MOV AL, 74    ; 74 �̤j
    MUL BL          ; 
    PUSH DX         ; ��JDX
    MOV DH, 0       ; DH �M��
    ADD AX, DX      ; �W�[AX ��DX��m
    POP DX          ; DX ���X 
    MOV ESI, 0      ; ESI �Ȧs�� �M��
	MOV SI, AX      ; AX�Ȧs���ǵ�SI���Э�
    SHL SI, 1       ; SI ���� ����
    MOV BX, A[SI]   ; A[SI] �}�C�� ����BX
    RET
accessIndex ENDP    
;---------------------------------------------------------------------------------------
saveIndex PROC USES EAX ESI EDX    ;DH DL �s�}�B EAX  ESI EDX   �ϥ�stack �覡   (�s����)
    PUSH EBX        ; 
    MOV BL, DH      ; 
    MOV AL, 74      ; 
    MUL BL          ; 
    PUSH DX         ; 
    MOV DH, 0       ; 
    ADD AX, DX      ; 
    POP DX          ; 
    MOV ESI, 0      ; 
    MOV SI, AX      ; 
    POP EBX         ; 
    SHL SI, 1       ; 
    MOV A[SI], BX   ;  �sBX����A[SI] �}�C��
    RET
saveIndex ENDP
;---------------------------------------------------------------------------------------
Paint PROC USES EAX EDX EBX ESI     ;�W��Ƶ{��
   MOV EAX, blue + (white * 16)   
   CALL SetTextColor
   MOV DH, 0                          
 RET
Paint ENDP
;---------------------------------------------------------------------------------------
END main