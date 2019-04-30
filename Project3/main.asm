TITLE Snake.asm
;2019/1/9
;期末報告

INCLUDE Irvine32.inc

.DATA

;lable 標籤宣告說明

a WORD 1800 DUP(0)  ; 周邊設定 row cloum
tailR BYTE 18d         ; 給蛇尾row  空間18d       
tailC BYTE 47d         ; 給蛇尾colum 空間47d
headR BYTE 13d         ; 蛇頭 row 空間13d
headC BYTE 47d         ; 蛇頭 colum 空間47d
foodR BYTE 0           ; 綠色食物 row fR1 標籤
foodC BYTE 0           ; 綠色食物 colum fC標簽

tmpR BYTE 0         ; 暫存row 值的標籤
tmpC BYTE 0         ; 暫存colum值的標籤

Up BYTE 0d          ; 設定往上標籤
Lf BYTE 0d          ; 設定往左標籤
Dn BYTE 0d          ; 設定往下標籤
Ri BYTE 0d          ; 設定往右標籤

eTail   BYTE    3d  ; 做為辦別吃到食物尾巴是否曾長標籤 
search  WORD    0d  ; 作為尋找標籤
eGame   BYTE    0d  ; 撞牆後結束的標籤
cScore  DWORD   0d  ; 總分顯示標籤

d       BYTE    'w' ; d 為當下作為蛇體判斷標籤
newD    BYTE    'w' ; newD 為新的蛇體蛇體判斷標籤
delTime DWORD   100 ; 速度設定100 

menuS   BYTE "按1,Start the Game" ,0     ;開始遊戲標籤
hitS    BYTE "Game over", 0  ; 遊戲結束標籤
scoreS  BYTE "Score: 0", 0  ;分數標籤

myHandle DWORD ?    ; 是否終止的input變數標籤
numInp   DWORD ?    ;  吃到食物的變數緩衝標籤 
temp BYTE 16 DUP(?) ; 向記憶體宣告16byte 暫存空間 (forINPUT_RECORD) 標籤
bRead    DWORD ?    ; 讀取暫存值的 假指令 irvine函示中提供

.CODE
;---------------------------------------------------------------------------------------
main PROC     ;主程式

menu:                           ;選單 function local 變數
    CALL Randomize              ;食物亂放 call副程式(Randmize)
    CALL Clrscr                 ; irvine 函數提供 清屏
    MOV EDX, OFFSET menuS       ; menuS 取出放到EDX暫存器
    CALL WriteString            ; irvine 提供 螢幕顯示
    
wait1:
	CALL ReadChar               ;irvine 提供 讀取字符 1回傳  開始  
    CMP AL, '1'                 ; 1號選單
    JE startG                   ;跳到開始遊戲畫面
	EXIT                        ;跳出 

startG:                     ; 遊戲開始設定function  local變數	
    MOV EAX, 0                  ; 清空暫存
    MOV EDX, 0                  ; 清空戰存 
    CALL Clrscr                 ; 
    CALL initSnake              ; 呼叫initSnake 副程式
  CALL createFood             ; 呼叫食物建立 createFood
    CALL startGame              ; 呼叫startGame 副程式
   CALL Paint                  ; 呼叫 paint (上色)副程式
  CALL SetTextColor           ; 呼叫settextcolor副程式
  
main ENDP      ;主程式結束
;---------------------------------------------------------------------------------------
initSnake PROC USES EBX EDX         ;副程式蛇體初始設定  13~18 row number 並寫入 framebuffer中

    MOV DH, 13      ; 設定 row number to 13
    MOV DL, 47      ; 設定 column number to 47
    MOV BX, 1       ; 第一個蛇體片段
    CALL saveIndex  ; 讀進 framebuffer
    MOV DH, 14      ; 
    MOV DL, 47      ; 
    MOV BX, 2       ; 第2個蛇體片段
    CALL saveIndex  ;
    MOV DH, 15      ; 
    MOV DL, 47      ; 
    MOV BX, 3       ; 第3個蛇體片段
    CALL saveIndex  ; 
    MOV DH, 16      ; 
    MOV DL, 47      ; 
    MOV BX, 4       ; 第4個蛇體片段
    CALL saveIndex  ;  
    MOV DH, 17     ; 
    MOV DL, 47      ; 
    MOV BX, 5       ; 第4個蛇體片段
    CALL saveIndex  ; 呼叫副程式  存入指標
 
 
    MOV DH, 18      ; 
    MOV DL, 47      ; 
    MOV BX, 6       ; 第5個蛇體片段
    CALL saveIndex  ; 
 RET                 ;回傳值
initSnake ENDP      ;初始蛇體副程式結束
;---------------------------------------------------------------------------------------
clearMem PROC       ;邊界設定副程式 (邊界觸碰設定)

    MOV DH, 0               ;設定 row DH暫存器為0
    MOV BX, 0               ;設定資料暫存器BX為0

    oLoop:                  ; 對 rows 子程式設定邊界
        CMP DH, 24          ; 最大24 超過死掉                      
        JE endOLoop         ; 跳到死亡子程式
		CALL saveIndex      ;呼叫saveindex 指標
		INC DH              ;寫入row暫存 DH
		JMP oLoop           ;繼續在oLoop 內圈執行 直到條成立 

    iLoop:              ;  對column設定子程式最大值
        CMP DL, 75      ; 
        JE endILoop     ; 
        CALL saveIndex  ;                          
        INC DL          ; 
		JMP iLoop       ;

    endILoop:               ; cloumn iloop結束 
	
	    INC DH              ; 寫入row DH暫存
        JMP oLoop           ; 跳到oloop外圈繼續

    endOLoop:               ; row oloop 結束
	    INC DL              ; 寫入row DH暫存
        JMP iLoop           ; 跳到iloop外圈繼續

clearMem ENDP  ;邊界副程式結束
;---------------------------------------------------------------------------------------
startGame PROC USES EAX EBX ECX EDX    ; 開始游戲富城程式   使用eax ebx ecx edx 暫存器
     MOV EAX, white + (blue * 16)       ; 顏色設定  ,藍底白字 (分數顯示code)
     CALL SetTextColor                   ; irvine 顏色設定funtion提供    
     MOV DH, 24                          ; 分數顯示位置row24
     MOV DL, 0                           ; coulum0
	 CALL GotoXY                         ; irvine 在主控制台顯示位置行列指定 funtion提供 
     MOV EDX, OFFSET scoreS       
	 CALL WriteString                    ;irvine顯示在主控制台功能提供

    ;標準輸入設定 masm內建 控制台輸入緩衝區設定 EAX
     INVOKE getStdHandle, STD_INPUT_HANDLE
     MOV myHandle, EAX
	 MOV ECX, 10

    ; 標準輸入設定 masm內建 從控制台中緩衝區 讀取數據設定
    INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
    INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead

    more:                        ;主要跑動的子程式函數

    ; 標準輸入設定 masm內建 從MYhandle中讀取資料
     INVOKE GetNumberOfConsoleInputEvents, myHandle, ADDR numInp
   
      MOV ECX, numInp
      CMP ECX, 0                          ; 檢查吃入的暫存ECX是否為空
      JE done                             ; 如果為空繼續跑

    ;從inputbuffer 讀取資料 並暫存至temp中
     INVOKE ReadConsoleInput, myHandle, ADDR temp, 1 , ADDR bRead
  
     MOV DX, WORD PTR temp               ; 確認是否為KEY_EVENT
     CMP DX, 1                           ; 存入DX (DX 不為1)
     JNE SkipEvent                       ; 吃入後的蛇體 要跳skipEvent
     MOV DL, BYTE PTR [temp+4]       ; 釋放暫存空間指標 DL
     CMP DL, 0                        ;DL 為0 
     JE SkipEvent                    ;跳至SKIPEVEN
     MOV DL, BYTE PTR [temp+10]      ; 讀取按壓見到 DL
     CMP DL, 1Bh                 ; 按ESC跳出  DL暫存地    (DL=1BH)
     JE quit                     ; 跳出 (quit)

     CMP d, 'w'                  ; 確認目前蛇的方向 (d="w")
	 JE case1                    ; 方向水平遇到 WS 改變方向為垂直
     CMP d, 's'                  ;      (d="s")
     JE case1                    ;   方向水平遇到 WS 改變方向為垂直
     JMP case2                   ; 方向垂直接跳CASE2
                                            
      case1:
                    CMP DL, 25h             ; 左陣列輸入  (DL=25h)
                    JE case11               ;  跳CASE11
                    CMP DL, 27h             ; 右邊陣列輸入 (DL=27h)
                    JE case12               ;跳CASE 12   
                    JMP SkipEvent           ; 如果是上下陣列輸入 不用改變方向  依樣在more這回圈執行
      case11:
                    MOV newD, 'a'       ; 設定新方向 a  為左
                    JMP SkipEvent
	  case12:
                    MOV newD, 'd'       ; 設定新方向d 為右
                    JMP SkipEvent        ;跳回more迴圈

      case2:
                    CMP DL, 26h             ; 上陣列輸入 (DL=26h)
                    JE case21               ;跳case21      
                    CMP DL, 28h             ; 下陣列輸入 (DL=28h)
                    JE case22               ;跳cace22
                    JMP SkipEvent           ; 若為左右輸入 繼續在more迴圈跑
                  
	  case21:
                    MOV newD, 'w'       ; 設定新方向往上
                    JMP SkipEvent       ;繼續跳回more迴圈跑 
      case22:
                    MOV newD, 's'       ; 設定新方向往下
                    JMP SkipEvent       ;繼續跳回more迴圈跑

    SkipEvent:    ;繼續跳回more 迴圈的 local 變數    
	JMP more                            ; 跳到more

    done:         ;轉變蛇體方向的 local 變數
        MOV BL, newD                        ; 新方向newD 存放入BL暫存                                           
        MOV d, BL                           ;讀取BL 變成現有方向 d 
        CALL MoveSnake                      ; 呼叫副程式  movesnake 告知現在的方向
        MOV EAX, DelTime                    ; 移出暫存給 DelTime
        CALL Delay                          ; 移動速度設定  呼叫 Delay
        CMP eGame, 1                        ; 結束標籤設定1  (eGame=1)
        JE quit                             ; 跳出迴圈
       JMP more                            ; 跳回more 迴圈

    quit:                                  ;跳出 副程式   local 變數
    RET              ;回傳startgame的值   
	
startGame ENDP   ;遊戲開始 副程式結束
;---------------------------------------------------------------------------------------
MoveSnake PROC USES EBX EDX      ;蛇體移動副程式  使用EBX EDX

        CMP eTail, 1            ; 去除走過尾八 標籤
        JNE NoETail             ; 如果沒標籤不要去除尾八 跳到 noetail
        MOV DH, tailR          ;  把蛇尾row 指標給DH
        MOV DL, tailC          ;  DL把蛇尾column 指標給DH
        CALL accessIndex    ;  呼叫accessindex 副程式 給DH DL指標
        DEC BX              ;  把值給BX 產生蛇體往前的下一個片段
        MOV search, BX      ; BX   複製BX的值給下一個蛇體的片段
        MOV BX, 0           ;  BX為 0 呼叫 saveindex 副程式
        CALL saveIndex      ; 把資料存進saveindex
        CALL GotoXY         ; invrine作者提公 清除非蛇體 ，蛇尾後走過的 螢幕顏色 
        MOV EAX, white + (black * 16)
        CALL SetTextColor   ;呼叫副程式 settextcolor 顏色設定副程式
        MOV AL, ' '          ; 空值  舍體走過處不上色
        CALL WriteChar       ;invrine 提供 讓一個單獨字元可標準輸出
        PUSH EDX            ; 放入EDX暫存中  
        MOV DL, 74
        MOV DH, 23         
        CALL GotoXY          ;invrine作者提公 清除非蛇體 ，蛇尾後走過的 螢幕顏色 
        POP EDX
        MOV AL, DH          ; 讀出DH  tail row 值 到AL
        DEC AL              ;    (上)
        MOV Up, AL          ; 把AL 值取出存入up
        ADD AL, 2           ;    (下)
        MOV Dn, AL          ; 把AL 值取出存入down
        MOV AL, DL          ; 讀取DL tail column 直到AL
        DEC AL              ; (左)
        MOV Lf, AL          ; 把AL值取出給 lift
        ADD AL, 2           ; (右)
        MOV Ri, AL          ; 把AL 值取出給right
        CMP Dn, 24          ; Down 超出24 row 範圍
        JNE next1           ; 跳 next 1 變數   
            MOV Dn, 0       ; 

     next1:
        CMP Ri, 74          ; right超出74 範圍(cP不等於74)
        JNE next2           ;跳next 2 變數
            MOV Ri, 0       ; 
     next2:
        CMP Up, 0           ;up(上標籤) > 0 
        JGE next3           ;跳 next 3變數 
            MOV Up, 23      ; 
     next3:
        CMP Lf, 0            ;lift(左標籤) > 0
        JGE next4          
            MOV Lf, 73      
     next4:
        MOV DH, Up          ;  up(上標籤)值傳給DH (row)
        MOV DL, tailC          ;    DL tC(蛇尾cloum)值傳給 DL (coloum)
        CALL accessIndex    ;   呼叫 accessindex 通行標籤副程式
        CMP BX, search      ; BX不等於serch
        JNE melseif1        ;跳到 melseif 變數
            MOV tailR, DH      ;移動tR(蛇尾到DH) 
            JMP mendoff      ;跳到mendoff標籤

     melseif1:           ;下的標籤 
        MOV DH, Dn          ; 
        CALL accessIndex    ; 
        CMP BX, search      ; BX不等於serch
        JNE melseif2
        MOV tailR, DH           ; 
        JMP mendoff        ; 跳出迴圈的標籤

     melseif2:           ;左的標籤
        MOV DH, tailR          ; tailR(蛇尾row值)給DH
        MOV DL, Lf          ; lift(當前column左邊)值給DL
        CALL accessIndex    ; 呼叫accessindex 副程式 把上面的東西放入 accessindex
        CMP BX, search      
        JNE melse           ;跳下一個melse 右標籤 
        MOV tailC, DL      ; tC(蛇體colunm)值 給DL
        JMP mendoff          ;跳出迴圈的標籤

    melse:              ;右的標籤  
        MOV DL, Ri      ; right (colunm 右)
        MOV tailC, DL      ;tC (蛇體cloum)   

    mendoff:             ;跳出迴圈標籤 

    NoETail:
        MOV eTail, 1            ;  設定清除尾巴標籤
        MOV DH, tailR              ;  複製row指標tR 給DH
        MOV DL, tailC              ; 複製column指標tR 給DL
        MOV tmpR, DH            ; 複製DH值至tmpR 暫存記憶體中
        MOV tmpC, DL            ; 複製DL值至tmpR 暫存記憶體中

    whileTrue:              ; 若為真 蛇體無窮迴圈
        MOV DH, tmpR        ; 當前 temR row指標 存至DH
        MOV DL, tmpC        ; 當前 temC colunm指標 存至DL
        CALL accessIndex    ; 呼叫 accessindex副程式 
        DEC BX              ;
        MOV search, BX      ; BX下個蛇體片段值給search
        PUSH EBX            ; 值stack 放入 EBX  後進先出
        ADD BX, 2           ; 
        CALL saveIndex      ;  呼叫副程式  蛇動 蛇體片段就跟著動
        POP EBX
        CMP BX, 0           ; BX 0  就是蛇頭0
        JE break            ; 跳至結束迴圈標籤
        MOV AL, DH          ; DH值給AL
        DEC AL              ; AL row 上面值
        MOV Up, AL          ; AL 存給Up(row上面值)
        ADD AL, 2           ; AL 下面值
        MOV Dn, AL          ; AL 存給down(row下面值)
        MOV AL, DL          ; 
        DEC AL              ; 左
        MOV Lf, AL          ; 左
        ADD AL, 2           ; 右
        MOV Ri, AL          ; 右
        CMP Dn, 24          ; 超出24 (下)
        JNE next21          ;跳到next21
        MOV Dn, 0       ; 清除走過的螢幕顯示

     next21:
       CMP Ri, 74         ; 超過74  (最大75) right不等於74
       JNE next22         ;跳到next22
       MOV Ri, 0       ; 清除走過的螢幕顯示

     next22:              ;最大24
       CMP Up, 0           ;up >= 0
       JGE next23       ;跳next23
       MOV Up, 23      ; 清除走過23piexl
	   
	 next23:           ;清除上一個走過的片段
       CMP Lf, 0           ; lift >=0
       JGE next24      ;跳24    
       MOV Lf, 73     ; 清除走過73 piexl

     next24:               ;      繼續望下一個片段移動標籤
       MOV DH, Up          ; 把up 值給 DH(row index)
       MOV DL, tmpC        ; 把colunm片段pixel(蛇體) 存入DL
       CALL accessIndex    ; 呼叫副程式 把值給accessindex
       CMP BX, search      ; BX不等於search
       JNE elseif21        ;跳elseif2-1
       MOV tmpR, DH    ; 移動下一格片段   DH 值給tmpR
       JMP endif2        ;跳endif2   (繼續在whileture 迴圈跑)

     elseif21:         
       MOV DH, Dn          ;  (row pixel值rD) 給DH
       CALL accessIndex    ;  呼叫副程式 accessindex 存入
       CMP BX, search      ; BX不等於 search  
       JNE elseif22         ;跳到elseif22 副程式
       MOV tmpR, DH    ;  繼續新的位置  DH 值給tmpR
       JMP endif2      ;跳endif2   (繼續在whileture 迴圈跑)

     elseif22:
        MOV DH, tmpR        ;  DH row pixel 左片段給DH
        MOV DL, Lf          ;  colunm pixel 左片段給DL
        CALL accessIndex    ; 呼叫副程式 accessindex 存入
        CMP BX, search      ;  BX不等於search  
        JNE else2           ;跳 else2 給右邊值          
        MOV tmpC, DL    ;  往右移動 DL值給tmpC 顯示在螢幕上
		JMP endif2         ;跳endif2   (繼續在whileture 迴圈跑)

      else2:
            MOV DL, Ri      ; right 往右值 給DL
            MOV tmpC, DL    ; DL 給 tmpC(暫存顯示)

      endif2:
        JMP whileTrue       ;繼續在whileTure 迴圈跑  值到頭碰尾

    break:                  ;終止條件 標籤
      MOV AL, headR              ; hR (蛇體'row)值 給AL
      DEC AL                  ; AL取值
      MOV Up, AL              ; AL值存入up(row上值減少)
      ADD AL, 2               ; AL 2 取下一個值
      MOV Dn, AL              ; AL值存入down(蛇下row 往下加)
      MOV AL, headC              ; hC (蛇體clunm)值 給AL
      DEC AL                  ; column AL取值
      MOV Lf, AL              ; AL值存入lift(colum左邊值 減少)
      ADD AL, 2               ;  AL 2 取下一個值
      MOV Ri, AL              ; AL值存入right(colum右邊值 增加)
      CMP Dn, 24              ; 確認24 邊界 down不等於24
      JNE next31              ;超過24 跳 next 31  
      MOV Dn, 0           ; 清除rP

    next31:
      CMP Ri, 74              ; 確認74邊界 right不等於74
      JNE next32              ;超過跳next32 
      MOV Ri, 0           ; 清除cP

   next32:
    CMP Up, 0               ; up>=0
    JGE next33              ;跳next 33
    MOV Up, 23          ; up移到23

   next33:
    CMP Lf, 0               ; lift>=0
    JGE next34               ;跳next34  
        MOV Lf, 73          ;lift移至73

    next34:                 ;總結上面走過的 把值存給DH DL
    CMP d, 'w'              ; 上"w" d不是"w"
    JNE elseif3             ;跳 elseif3
        MOV AL, Up          ; row 頭放入新位置 up值給AL
        MOV headR, AL          ; AL 給 hR 
        JMP endif3          ;存值給 DH DL

    elseif3:
    CMP d, 's'              ; 下"s"   d不是"s"
    JNE elseif32            ; 跳 elseif32 
        MOV AL, Dn          ; 
        MOV headR, AL          ; 
        JMP endif3          ;存值給 DH DL

    elseif32:
    CMP d, 'a'              ; 左"a"  d不是"a"
    JNE else3
        MOV AL, Lf          ; 
        MOV headC, AL          ; 存值給 DH DL
        JMP endif3

    else3:                  ;右 
        MOV AL, Ri           
        MOV headC, AL          

    endif3:                 ;存值 給DH DL
    MOV DH, headR              ; 新row 頭
    MOV DL, headC              ; 新col頭
    CALL accessIndex        ; 呼叫副程式 accessindex 把DH DL 值存入
    CMP BX, 0               ; BX= 0
    JE NoHit                ; 跳nohit
    MOV DH, 24              ; 
    MOV DL, 11              ; 
    CALL GotoXY              ;作者函數提供
    CALL WriteString         ;作者函數提供
    CALL Delay              ; 作者函數提供 延緩
    MOV eGame, 1            ; eGame 標籤1 遊戲結束
    RET                     ; 

 NoHit:                     ; 沒吃到食物標籤設定
    MOV BX, 1               ; 
    CALL saveIndex          ; 
    MOV cl, foodC              ; 食物 col (cl記憶體)
    MOV ch, foodR              ; 食物 row (ch記憶體)
    CMP cl, DL              ; 比較 蛇頭 column 和食物 column (c1不等於DL)
    JNE foodNotGobbled      ;跳(foodnotgobbled)沒吃到食物
    CMP ch, DH              ; 比較 蛇頭 row 和食物 row    (ch不等於DH)
    JNE foodNotGobbled      ;跳(foodnotgobbled)沒吃到食物
    CALL createFood         ; 食物被吃  呼叫 careatefood副程式
    MOV eTail, 0            ;                           
	MOV EAX, white + (black * 16)  ;設定顏色
    CALL SetTextColor       ;作者提供
    PUSH EDX                ; Push EDX onto stack
    MOV DH, 24              ; 分數落點處
    MOV DL, 7               ;分數落點處         
    CALL GotoXY             ;作者提供
    MOV EAX, cScore         ; 分數計算  
    INC EAX
    CALL WriteDec
    MOV cScore, EAX         ; 更新分數計算
    POP EDX                 ; Pop EDX off of stack

    foodNotGobbled:         ; 沒吃到食物標籤
    CALL GotoXY             ; 作者提供  
    MOV EAX, blue + (white * 16)
    CALL setTextColor       ;
    MOV AL, ' '             ;
    CALL WriteChar           ;
    MOV DH, 24             ; DH 24  這樣就永遠不會撞牆
    MOV DL, 74             ; DL 74  這樣就永不撞牆
    CALL GotoXY
    RET                     
MoveSnake ENDP             ;蛇體移動副程式結束
;---------------------------------------------------------------------------------------
createFood PROC USES EAX EBX EDX
 redo:                       ; 建立食物的標籤
    MOV EAX, 20                 ; 設定20 
    CALL RandomRange            ; range 0 to numRows - 1  作者提供 隨機放
    MOV DH, AL
    MOV EAX, 60                ; 設定60
    CALL RandomRange            ; range 0 to numCol - 1 作者提供 隨機放
    MOV DL, AL
    CALL accessIndex            ; 呼叫副程式 accessindex
    CMP BX, 0                   ; BX 0則
    JNE redo                    ;跳回 redo
    MOV foodR, DH                  ; 設定食物row值
    MOV foodC, DL                  ; 設定食物col值
    MOV EAX, white + (cyan * 16); 食物顏色設定
    CALL setTextColor           ;作者提供
    CALL GotoXY                 ; 作者提供
    MOV AL, ' '                 ; 
    CALL WriteChar               ;作者提供
    RET
createFood ENDP
;---------------------------------------------------------------------------------------
accessIndex PROC USES EAX ESI EDX    ;DH  DL 中pixel回傳 framebuffer， value值 再回傳到BX暫存器  (取指標) 
    MOV BL, DH      ; DH中row 的值傳給 BL
    MOV AL, 74    ; 74 最大
    MUL BL          ; 
    PUSH DX         ; 放入DX
    MOV DH, 0       ; DH 清空
    ADD AX, DX      ; 增加AX 取DX位置
    POP DX          ; DX 取出 
    MOV ESI, 0      ; ESI 暫存器 清空
	MOV SI, AX      ; AX暫存器傳給SI指標值
    SHL SI, 1       ; SI 指標 標籤
    MOV BX, A[SI]   ; A[SI] 陣列中 指給BX
    RET
accessIndex ENDP    
;---------------------------------------------------------------------------------------
saveIndex PROC USES EAX ESI EDX    ;DH DL 存址處 EAX  ESI EDX   使用stack 方式   (存指標)
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
    MOV A[SI], BX   ;  存BX直到A[SI] 陣列中
    RET
saveIndex ENDP
;---------------------------------------------------------------------------------------
Paint PROC USES EAX EDX EBX ESI     ;上色副程式
   MOV EAX, blue + (white * 16)   
   CALL SetTextColor
   MOV DH, 0                          
 RET
Paint ENDP
;---------------------------------------------------------------------------------------
END main