TITLE nina
;2018/12/28
;HW-5107056031   康淨依

INCLUDE Irvine32.inc
.DATA

;lable標籤型別設定 , 為了讓 jmp可跳

operator DWORD ?  ; 運算子型別設定 doubleword (32byte)
firstNumber DWORD ? ;第一運算元型別設定 
secondNumber DWORD ? ;第二運算元型別設定 
result DWORD ? ;結果值型別設定 
filename BYTE "result.txt",0 ;byte ,標籤不占空間  存放答案檔案
filehandle DWORD ?     ;double word 不設初始值

welcome BYTE "welcome",0
lineMenu BYTE " ",0 ;選單顯示
chose  BYTE  "運算子輸入: +請按1,-請按2,*請按3,/請按4 ",0;選擇運算子

string BYTE sizeof result DUP(0),0,0  ;在記憶體宣告要 result 的空間, 標籤不占空間
string1  BYTE  "input first number:",0  ;第1運算元
string2  BYTE  "input second number:",0  ;地2運算元

ResultMsg BYTE "your result:",0    ;2數運算結果

errormsg BYTE "bye bye",0  ;  運算結束標籤 不占空間
.stack 100       ;堆疊數100

savereg MACRO     ;使用巨集處理
        push eax   ;堆疊運算指令
		push ebx
		push ecx
		push edx
		push esi
		push edi
ENDM  ;標籤宣告結束
.code

main PROC           ;主程式
mov edx,OFFSET welcome
call WriteString  ;inrvine的參數
call CrLf         ;inrvine跳下一行
call CrLf         ;inrvine的參數

fileOperate:      ;副程式調用運算  local變數
      
        mov edx,OFFSET filename  ;name 標籤內容 result.txt 放入 edx
		call CreateOutputFile    ;call createoutputfile 副程式 
		cmp ax, INVALID_HANDLE_VALUE      ;原內建函數   上述createoutput若為無效值關閉
		je file_error     ;因上述為無效  跳至 fileerror副程式
		mov filehandle,eax  ;filehandle 般至eax
		jmp displaymenustart  ;跳 displaymenustrat 副程式

file_error:     ;副程式 檔案錯誤  local 變數
       mov edx,OFFSET errormsg   ;errormsg 放入 edx暫存器
	   call WriteString
	   call CrLf                     ;irvine32中的內建換行函數
	   jmp stop_run  ;跳到停止計算

displaymenustart:         ;運算顯示函數
   

chosefunction:             ;選擇+-*/功能副程式   local變數
    
	 mov edx,OFFSET chose   ;chose 讀入的值存至 edx
	  call WriteString
	  call CrLf
	  call ReadInt
	  cmp eax,1         ;  比較 ZF(zero flag  與CF 進位 flag) 用在減與乘  ,放入eax暫存中
	  jb chosefunction       ;"+"不正確跳副程式chosefuntion    
	  cmp eax,4            ;"/"不正確跳副程式inputerror  
	  jg chosefunction       ;不正確跳副程式chosefuntion      

inputnumber:                  ;讀取輸入數字 副程式  local
     mov operator,eax      ;operator 放入eax
	 mov edx,OFFSET string1 ; 第一個數字 移出edx
	 call WriteString       ;irvine 中的呼叫字串到標準輸出函數
	 call ReadInt            
	 mov firstNumber,eax     ;第一個樹移入 eax暫存中
	 mov edx,OFFSET string2  ;地2格數已出edx
	 call WriteString
	 call ReadInt
	 mov secondNumber,eax     ;地2運算元移入 eax暫存
	 call CrLf               
	 mov eax,operator       ;放入運算子 eax
	 cmp eax,1              ;1為加   ,eax 開始計算  讀取1
	 je addFunction          ;跳加法子程式
	 cmp eax,2               ;2為減  ,eax 開始計算  讀取2
	 je subFunction            ;跳減法子程式
	 cmp eax,3                ;3為乘  eax 開始計算  讀取3
	 je mulFunction            ;跳乘法子程式
	 cmp eax,4                ;4為除  eax 開始計算  讀取4
	 je divFunction             ;跳除法子程式

addFunction:  ;加法整數運算 副程式  local
    mov eax,firstNumber ;搬到暫存器
	add eax,secondNumber ;第2個數字加上   
	jmp displayResult   ;跳出相加結果  到 displayresult

subFunction:          ;減法整數運算 副程式
    mov eax,firstNumber  ;第一個搬到暫存器
	sub eax,secondNumber  ;減第2數字上去
	jmp displayResult  ;跳出相減結果

mulFunction:               ;乘法整數運算指副程式
    mov eax,firstNumber
	imul eax,secondNumber
	jmp displayResult

divFunction:                   ;除法整數運算副程式
    mov eax,secondNumber
	cmp eax,0                  
	mov edx,0
	mov eax,firstNumber
	idiv secondNumber
	jmp displayResult

displayResult:             ;運算結果副程式
    mov result,eax         ;eax暫存器取出result 
    mov edx,OFFSET ResultMsg   ;回給 addResutMsg
	call WriteString
	call WriteInt
	call CrLf
	call CrLf

	;調用寫入函數
	pushf        ;堆疊的推入
	call copy_file    ;push 的資料進到 write to file
	popf         ;堆疊取出
	cmp eax,7
	je close_file  ;file 都沒資料 結束 file

close_file:           ;結束函數

stop_run:               ;停止運算函數 
	call CrLf
	call WaitMsg      ;螢幕顯示 press [] to continue.......的指令
	exit

	ret
main ENDP                   ;主程式結束


copy_file PROC   ;寫入暫存副程式   32位元組的運算
   savereg
   mov edx,OFFSET string
   mov eax,result
   shr eax,28        ; 28位元組
   add al,30h        ; 加法 記憶體空間30h   
   cmp al,58     
   jl L1             ;跳L1  ,stack 搭配的loop lable  32位元
   add al,7

L1:
   mov byte ptr [edx],al    ;
   inc edx
   mov eax,result
   shr eax,24       ;24位元
   and ax,1111b     ;1111b 位元
   add al,30h       ;加法 30h
   cmp al,58
   jb L2            ;跳L2 
   add al,7

L2:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,20        ;20位元
   and ax,1111b
   add al,30h
   cmp al,58
   jl L3
   add al,7

L3:
   mov byte ptr [edx],al
   inc dx
   mov eax,result
   shr eax,16        ;16位元
   and ax,1111b
   add al,30h
   cmp al,58
   jl L4
   add al,7

L4:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,12           ;12位元
   and ax,1111b
   add al,30h
   cmp al,58
   jl L5
   add al,7

L5:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,8              ;8位元
   and ax,1111b
   add al,30h
   cmp al,58
   jl L6
   add al,7

L6:
   mov byte ptr [edx],al
   inc edx
   mov eax,result
   shr eax,4              ;4位元
   and ax,1111b
   add al,30h
   cmp al,58
   jl L7
   add al,7

L7:                       ;0位元
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
copy_file ENDP  ;副程式結束

exit     ;結束跳出

end main   ;全部程式結束
   
    