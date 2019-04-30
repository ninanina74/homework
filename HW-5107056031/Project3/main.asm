TITLE nina
;2018/12/28
;HW-5107056031   �d�b��

INCLUDE Irvine32.inc
.DATA

;lable���ҫ��O�]�w , ���F�� jmp�i��

operator DWORD ?  ; �B��l���O�]�w doubleword (32byte)
firstNumber DWORD ? ;�Ĥ@�B�⤸���O�]�w 
secondNumber DWORD ? ;�ĤG�B�⤸���O�]�w 
result DWORD ? ;���G�ȫ��O�]�w 
filename BYTE "result.txt",0 ;byte ,���Ҥ��e�Ŷ�  �s�񵪮��ɮ�
filehandle DWORD ?     ;double word ���]��l��

welcome BYTE "welcome",0
lineMenu BYTE " ",0 ;������
chose  BYTE  "�B��l��J: +�Ы�1,-�Ы�2,*�Ы�3,/�Ы�4 ",0;��ܹB��l

string BYTE sizeof result DUP(0),0,0  ;�b�O����ŧi�n result ���Ŷ�, ���Ҥ��e�Ŷ�
string1  BYTE  "input first number:",0  ;��1�B�⤸
string2  BYTE  "input second number:",0  ;�a2�B�⤸

ResultMsg BYTE "your result:",0    ;2�ƹB�⵲�G

errormsg BYTE "bye bye",0  ;  �B�⵲������ ���e�Ŷ�
.stack 100       ;���|��100

savereg MACRO     ;�ϥΥ����B�z
        push eax   ;���|�B����O
		push ebx
		push ecx
		push edx
		push esi
		push edi
ENDM  ;���ҫŧi����
.code

main PROC           ;�D�{��
mov edx,OFFSET welcome
call WriteString  ;inrvine���Ѽ�
call CrLf         ;inrvine���U�@��
call CrLf         ;inrvine���Ѽ�

fileOperate:      ;�Ƶ{���եιB��  local�ܼ�
      
        mov edx,OFFSET filename  ;name ���Ҥ��e result.txt ��J edx
		call CreateOutputFile    ;call createoutputfile �Ƶ{�� 
		cmp ax, INVALID_HANDLE_VALUE      ;�줺�ب��   �W�zcreateoutput�Y���L�ĭ�����
		je file_error     ;�]�W�z���L��  ���� fileerror�Ƶ{��
		mov filehandle,eax  ;filehandle ���eax
		jmp displaymenustart  ;�� displaymenustrat �Ƶ{��

file_error:     ;�Ƶ{�� �ɮ׿��~  local �ܼ�
       mov edx,OFFSET errormsg   ;errormsg ��J edx�Ȧs��
	   call WriteString
	   call CrLf                     ;irvine32�������ش�����
	   jmp stop_run  ;���찱��p��

displaymenustart:         ;�B����ܨ��
   

chosefunction:             ;���+-*/�\��Ƶ{��   local�ܼ�
    
	 mov edx,OFFSET chose   ;chose Ū�J���Ȧs�� edx
	  call WriteString
	  call CrLf
	  call ReadInt
	  cmp eax,1         ;  ��� ZF(zero flag  �PCF �i�� flag) �Φb��P��  ,��Jeax�Ȧs��
	  jb chosefunction       ;"+"�����T���Ƶ{��chosefuntion    
	  cmp eax,4            ;"/"�����T���Ƶ{��inputerror  
	  jg chosefunction       ;�����T���Ƶ{��chosefuntion      

inputnumber:                  ;Ū����J�Ʀr �Ƶ{��  local
     mov operator,eax      ;operator ��Jeax
	 mov edx,OFFSET string1 ; �Ĥ@�ӼƦr ���Xedx
	 call WriteString       ;irvine �����I�s�r���зǿ�X���
	 call ReadInt            
	 mov firstNumber,eax     ;�Ĥ@�Ӿ𲾤J eax�Ȧs��
	 mov edx,OFFSET string2  ;�a2��Ƥw�Xedx
	 call WriteString
	 call ReadInt
	 mov secondNumber,eax     ;�a2�B�⤸���J eax�Ȧs
	 call CrLf               
	 mov eax,operator       ;��J�B��l eax
	 cmp eax,1              ;1���[   ,eax �}�l�p��  Ū��1
	 je addFunction          ;���[�k�l�{��
	 cmp eax,2               ;2����  ,eax �}�l�p��  Ū��2
	 je subFunction            ;����k�l�{��
	 cmp eax,3                ;3����  eax �}�l�p��  Ū��3
	 je mulFunction            ;�����k�l�{��
	 cmp eax,4                ;4����  eax �}�l�p��  Ū��4
	 je divFunction             ;�����k�l�{��

addFunction:  ;�[�k��ƹB�� �Ƶ{��  local
    mov eax,firstNumber ;�h��Ȧs��
	add eax,secondNumber ;��2�ӼƦr�[�W   
	jmp displayResult   ;���X�ۥ[���G  �� displayresult

subFunction:          ;��k��ƹB�� �Ƶ{��
    mov eax,firstNumber  ;�Ĥ@�ӷh��Ȧs��
	sub eax,secondNumber  ;���2�Ʀr�W�h
	jmp displayResult  ;���X�۴�G

mulFunction:               ;���k��ƹB����Ƶ{��
    mov eax,firstNumber
	imul eax,secondNumber
	jmp displayResult

divFunction:                   ;���k��ƹB��Ƶ{��
    mov eax,secondNumber
	cmp eax,0                  
	mov edx,0
	mov eax,firstNumber
	idiv secondNumber
	jmp displayResult

displayResult:             ;�B�⵲�G�Ƶ{��
    mov result,eax         ;eax�Ȧs�����Xresult 
    mov edx,OFFSET ResultMsg   ;�^�� addResutMsg
	call WriteString
	call WriteInt
	call CrLf
	call CrLf

	;�եμg�J���
	pushf        ;���|�����J
	call copy_file    ;push ����ƶi�� write to file
	popf         ;���|���X
	cmp eax,7
	je close_file  ;file ���S��� ���� file

close_file:           ;�������

stop_run:               ;����B���� 
	call CrLf
	call WaitMsg      ;�ù���� press [] to continue.......�����O
	exit

	ret
main ENDP                   ;�D�{������


copy_file PROC   ;�g�J�Ȧs�Ƶ{��   32�줸�ժ��B��
   savereg
   mov edx,OFFSET string
   mov eax,result
   shr eax,28        ; 28�줸��
   add al,30h        ; �[�k �O����Ŷ�30h   
   cmp al,58     
   jl L1             ;��L1  ,stack �f�t��loop lable  32�줸
   add al,7

L1:
   mov byte ptr [edx],al    ;
   inc edx
   mov eax,result
   shr eax,24       ;24�줸
   and ax,1111b     ;1111b �줸
   add al,30h       ;�[�k 30h
   cmp al,58
   jb L2            ;��L2 
   add al,7

L2:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,20        ;20�줸
   and ax,1111b
   add al,30h
   cmp al,58
   jl L3
   add al,7

L3:
   mov byte ptr [edx],al
   inc dx
   mov eax,result
   shr eax,16        ;16�줸
   and ax,1111b
   add al,30h
   cmp al,58
   jl L4
   add al,7

L4:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,12           ;12�줸
   and ax,1111b
   add al,30h
   cmp al,58
   jl L5
   add al,7

L5:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,8              ;8�줸
   and ax,1111b
   add al,30h
   cmp al,58
   jl L6
   add al,7

L6:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,4              ;4�줸
   and ax,1111b
   add al,30h
   cmp al,58
   jl L7
   add al,7

L7:                       ;0�줸
   mov byte ptr [edx],al    
   inc edx
   mov eax,result
   and ax,1111b
  add al,30h
   cmp al,58
   jl L8
   add al,7

L8:
   mov byte ptr [edx],al
   inc edx
   mov byte ptr [edx],al
   inc edx
   mov byte ptr [edx],0dh
   inc edx
   mov byte ptr [edx],0ah

   mov eax,handle
   mov edx,OFFSET string
   call WriteToFile
   ret
copy_file ENDP  ;�Ƶ{������

exit     ;�������X

end main   ;�����{������
   
    