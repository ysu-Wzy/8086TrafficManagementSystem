;=======================================================
; �ļ���: traffic.asm
; ��������: ��ͨ�ƿ���ϵͳ
;     8255�� B�ڿ�������ܵĶ���ʾ��
;            A�ڿ��Ƽ�����ɨ�輰����ܵ�λ������
;            C�ڿ��Ƽ��̵���ɨ�衣
;=======================================================

IOY0         EQU   0600H          ;ƬѡIOY0��Ӧ�Ķ˿�ʼ��ַ
MY8255_A     EQU   IOY0+00H*2     ;8255��A�ڵ�ַ
MY8255_B     EQU   IOY0+01H*2     ;8255��B�ڵ�ַ
MY8255_C     EQU   IOY0+02H*2     ;8255��C�ڵ�ַ
MY8255_CON   EQU   IOY0+03H*2     ;8255�Ŀ��ƼĴ�����ַ

A8254      EQU 06C0H                          	;8254������0�˿ڵ�ַ
B8254      EQU 06C2H                          	;8254������1�˿ڵ�ַ
C8254      EQU 06C4H                          	;8254������2�˿ڵ�ַ
CON8254    EQU 06C6H                          	;8254 ���ƼĴ����˿ڵ�ַ
    
SSTACK SEGMENT STACK
	       DW 200 DUP(?)
SSTACK	ENDS		

DATA SEGMENT

	; DATBLE�� ����Ҫ���밴����ֵ��Ӧ��Ҫ������ʾ����ֵ
	; ���簴��1��ʾ��ֵ��1 ���������͸���ʾ������06H
	; �ó�����ͨ���жϰ������� ��ȡ������ƫ�����������DTABLE��
	; ���簴��1��ƫ������1 ����ɨ�谴�� �ó�һ��ֵ 1
	; Ȼ�����ø�ֵ��DTABLE���ҵ���Ҫ���ֵ�Ķ�Ӧ��ʾ����ֵ
	; ��B���ͳ�ȥ����


	TIME_COUNT DW 0                              	;��ʱ����λΪs

	STATE      DW ?,?,?,?                        	;ÿ��״̬�Ľ���ʱ��
	GREEN      DW 0AH
	YELLOW     DW 03H

	;������|-----------------|----|----------------------|
	;      �� 40s              ��5s       �� 45s
	;�ϱ���|----------------------|-----------------|----|
	;      �� 45s                    ��  40s         ��5s

	; STATE1: PA6-PC7 ��-��
	; STATE2: PA4-PC7 ��-��
	; STATE3: PA7-PC6 ��-��
	; STATE4: PA7-PC5 ��-��
	DTABLE     DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H
	           DB 7FH,6FH,77H,7CH,39H,5EH,79H,71H

	CD         DB ?,?,?,?,?,?                    	;�������ʾ������

	A_SUB      DB ?                              	;A�ڵ�PA7��PA6
	CX_SUB     DW 0                              	;���ж�ʱ��CXֵ�����壺ʱ��

	LED_A      DB 0H


DATA  	ENDS

CODE SEGMENT
	           ASSUME CS:CODE,DS:DATA
	START:     
	;===========================================
	; ��ʼ��
	;===========================================
	           MOV    AX, DATA
	           MOV    DS, AX
	           XOR    CX,CX
	           CALL   INIT_TIME

 		
	; ��CD�е�ֵȫ����ʼ��Ϊ00H
	; ˵����ʼƫ����ȫΪ0
	           MOV    SI,OFFSET CD
	           MOV    AL,00H
		
	           MOV    [SI],AL         	;����ʾ����
	           MOV    [SI+1],AL
	           MOV    [SI+2],AL
	           MOV    [SI+3],AL
	           MOV    [SI+4],AL
	           MOV    [SI+5],AL

	; �ж�����������
	           PUSH   DS
	           MOV    AX, 0H
	           MOV    DS, AX
	           MOV    AX, OFFSET MIR7 	;ȡ�ж���ڵ�ַ
	           MOV    SI, 003CH       	;�ж�ʸ����ַ
	           MOV    [SI], AX        	;��MIR7��ƫ��ʸ��
	           MOV    AX, CS          	;�ε�ַ
	           MOV    SI, 003EH
	           MOV    [SI], AX        	;��MIR7�Ķε�ַʸ��

	           MOV    AX, 0H
	           MOV    DS, AX
	           MOV    AX, OFFSET MIR6 	;ȡ�ж���ڵ�ַ
	           MOV    SI, 0038H       	;�ж�ʸ����ַ
	           MOV    [SI], AX        	;��MIR6��ƫ��ʸ��
	           MOV    AX, CS          	;�ε�ַ
	           MOV    SI, 003AH
	           MOV    [SI], AX        	;��MIR6�Ķε�ַʸ��

	           CLI
	           POP    DS
	;��ʼ����Ƭ8259
	           MOV    AL, 11H
	           OUT    20H, AL         	;ICW1
	           MOV    AL, 08H
	           OUT    21H, AL         	;ICW2
	           MOV    AL, 04H
	           OUT    21H, AL         	;ICW3
	           MOV    AL, 01H
	           OUT    21H, AL         	;ICW4
	           MOV    AL, 2FH         	;OCW1
	           OUT    21H, AL
	;INIT 8255
	           MOV    DX,MY8255_CON
	           MOV    AL,81H
	           OUT    DX,AL
	;8254
	           MOV    DX, CON8254     	;8254
	           MOV    AL, 36H         	;0011 0110������0����ʽ3
	           OUT    DX, AL
	           MOV    DX, A8254
	           MOV    AL, 10H         	;03E8H  --> 1000
	           OUT    DX, AL
	           MOV    AL, 27H
	           OUT    DX, AL


	           MOV    DI,OFFSET CD+5
	           STI
	
	;===========================================
	; ������
	;===========================================
	BEGIN:     MOV    SI,OFFSET CD
	           MOV    AL,00H
	           MOV    [SI+4],AL
	           MOV    [SI+5],AL
	           CALL   DIS
	           CALL   CLEAR
	           JMP    BEGIN

	;===========================================
	; CLEAR �����ӳ���
	;===========================================
	;����ʹ�����еĵ�Ϩ�� 00H��ʾȫ���� ˲�� �ܿ�
	CLEAR:     MOV    DX,MY8255_B
	           MOV    AL,00H
	           OUT    DX,AL
	           RET

	;===========================================
	; DIS ��ʾ�ӳ���
	;===========================================
	DIS:       PUSH   AX
	           MOV    SI,OFFSET CD

	; 0DFH=1101 1111 ��ӦPA7 PA6 PA5...PA1 PA0
	; �ɵ�·ͼ �ó� X1-PA0 X2-PA1.....
	; 6����ʾ�� ������������ X1 X2 X3... X5 X6
	; ���� ��Ӧ��PA:          PA0 PA1 PA2 PA3 PA4 PA5
	; �����ʼ��0DFH   ����     1   1   1   1   1   0
	; ��˼�� ��������ʾ ��ʼ��ʾ����
	; ���� ������ʵ�Ǵ�X6��X1������ʾ��
	; ÿ��������ʾ����ܿ� ���ǻ���Ϊ��6������һ����ʾ ��ʵ�������ʾ
	           MOV    DL,0DFH
	           MOV    AL,DL

	AGAIN:     PUSH   DX
	; ��AL�͸�A�� ���ÿ����ĸ��� ������Ҫ����·ͼ A��Ҳ���ƵƵĿ��ţ�
	           MOV    DX,MY8255_A

	           PUSH   AX              	;��PA7 PA6���⴦��
	           AND    AL,3FH
	           MOV    BL,[LED_A]
	           OR     AL,BL
	           OUT    DX,AL
	           POP    AX
		
	           MOV    AL,[SI]         	; ��3000H--3005H�д��ƫ��������ԣ�ȡ��
	           MOV    BX,OFFSET DTABLE	; ��ȡDTABLE���׵�ַ
	           AND    AX,00FFH        	; ��Ϊ������мӷ����� �Ȱ�ah��0 ����ax����
	; al��ֵ����ֹ����
	           ADD    BX,AX           	; ��ȡ��Ҫ��ֵ��ƫ����������Ǿ���ƫ������
	           MOV    AL,[BX]         	; ��ȡ��ʾ������Ҫ��ֵ �� ��ʾ0��Ҫ3FH
	
	           MOV    DX,MY8255_B     	; ����B�� ��ʾ����       12-1\2
	           OUT    DX,AL
	
	           CALL   DALLY           	; ��ʱ
	           INC    SI              	; �ƶ�SI ��ȡ��һ��ƫ����
	           POP    DX
	           MOV    AL,DL           	; DL: �����ĸ��ƵĿ��� ��ʼ��0DF 1101 1111
	; ȡ��6λ������·ͼ ֻ����6���ߣ���01 1111
	; ��ֵ��AL
	           TEST   AL,01H          	; ����AL ���Ƿ�Ϊ11 1110
	; 6���� һ����ʾ��Ҫѭ��6��
	; ��������ν����� AL=11 1110
	; ���ڵ� ����x1����ʾ�꣨�ƣ�X6->X1��
	           JZ     OUT1            	; 6��ѭ����ɺ� ����
	           ROR    AL,1            	; ѭ������
	; �� ��һ������ AL=01 1111
	;  �� �ڶ������� Ϊ 10 1111
	;  ������Ҫѭ������
	;  ��ӳ�ڵ��� �������ƣ���Ҫ�ƽ�ȥ��Ŷ��
	           MOV    DL,AL
	           JMP    AGAIN           	; ���� ������ʾ ��ѭ��6��
	OUT1:      POP    AX
	           RET

	;===========================================
	; DALLY�ӳ��� ��ʱ���� RETΪ�ӳ���������
	;===========================================
	DALLY:     PUSH   CX
	           MOV    CX,0006H
	T1:        MOV    AX,009FH
	T2:        DEC    AX
	           JNZ    T2
	           LOOP   T1
	           POP    CX
	           RET

	;===========================================
	; PUTBUF
	;===========================================
	; ����õ�ƫ��������CD��
	; ���ں������ʾ
	; ��ʾ��ʵ���Ǵ�CD�ж�ȡƫ����
	; Ȼ����table���ҵ�������ֵ����
	PUTBUF:    MOV    SI,DI           	;�����ֵ����Ӧλ�Ļ�����
	           MOV    [SI],AL         	;�ȴ����ַCD+5 �ٵݼ� Ҳ������һ������ƫ��������CD+4
	           DEC    DI
	           MOV    AX,OFFSET CD-1
	           CMP    DI,AX
	           JNZ    GOBACK
	           MOV    DI,OFFSET CD+5
	GOBACK:    RET


	;===========================================
	; MIR7
	;===========================================
	MIR7:      
	           PUSH   AX
	           PUSH   BX
	           PUSH   CX
	           PUSH   DX
	           MOV    AX,[TIME_COUNT]
	           INC    AX
	           MOV    [TIME_COUNT],AX
	           CMP    AX,100
	           JNE    MID
			 
	           XOR    AX,AX
	           MOV    [TIME_COUNT],AX
			 
	           MOV    DX, A8254
	           MOV    AL, 10H         	;2710H  --> 1000
	           OUT    DX, AL
	           MOV    AL, 27H
	           OUT    DX, AL
	           MOV    CX,[CX_SUB]
	           CMP    CX,[STATE]
	           JL     STATE1
	           MOV    BX,[STATE+2]
	           CMP    CX,BX
	           JL     STATE2
	           MOV    BX,[STATE+4]
	           CMP    CX,BX
	           JL     JMP_STATE3
	           MOV    BX,[STATE+6]
	           CMP    CX,BX
	           JL     JMP_STATE4
	           XOR    CX,CX           	;����
	           JMP    STATE1
           
	STATE1:    MOV    AX,0131H        	; ��-�� A��40H C:80H
	           INT    10H
	           MOV    DX,MY8255_A
	           MOV    AL,80H
	           MOV    [LED_A],AL
	           OUT    DX,AL
	           MOV    [A_SUB],AL
	           MOV    DX,MY8255_C
	           MOV    AL,40H
	           OUT    DX,AL
	;����ʱ
	           MOV    AX,[STATE]
	           SUB    AX,CX
	           MOV    BL,0AH
	           DIV    BL
	           MOV    [CD],AH         	;��������λ
	           MOV    [CD+1],AL
	           MOV    AX,[STATE+2]
	           SUB    AX,CX
	           DIV    BL
	           MOV    [CD+2],AH
	           MOV    [CD+3],AL
			  
	           JMP    NEXT
	          
	MID:       JMP    RETURN
	JMP_STATE3:JMP    STATE3
	STATE2:    MOV    AX,0132H        	; ��-�� A��10H C��80H
	           INT    10H
	           MOV    DX,MY8255_A
	           MOV    AL,80H
	           MOV    [LED_A],AL

	           OUT    DX,AL
	           MOV    [A_SUB],AL
	           MOV    DX,MY8255_C
	           MOV    AL,20H
	           OUT    DX,AL
	;����ʱ
	           MOV    AX,[STATE+2]
	           SUB    AX,CX
	           MOV    BL,0AH
	           DIV    BL
	           MOV    [CD],AH         	;��������λ
	           MOV    [CD+1],AL       	;������ʮλ
	           MOV    AX,[STATE+2]
	           SUB    AX,CX
	           DIV    BL
	           MOV    [CD+2],AH
	           MOV    [CD+3],AL
	           JMP    NEXT

	JMP_STATE4:JMP    STATE4
	STATE3:    MOV    AX,0133H        	; ��-�� A��80H C:40H
	           INT    10H
	           MOV    DX,MY8255_A
	           MOV    AL,40H
	           MOV    [LED_A],AL

	           OUT    DX,AL
	           MOV    [A_SUB],AL
	           MOV    DX,MY8255_C
	           MOV    AL,80H
	           OUT    DX,AL
	;����ʱ
	           MOV    AX,[STATE+6]
	           SUB    AX,CX
	           MOV    BL,0AH
	           DIV    BL
	           MOV    [CD],AH         	;��������λ
	           MOV    [CD+1],AL       	;������ʮλ
	           MOV    AX,[STATE+4]
	           SUB    AX,CX
	           DIV    BL
	           MOV    [CD+2],AH
	           MOV    [CD+3],AL
	           JMP    NEXT
	STATE4:    MOV    AX,0134H        	; ��-�� A��80H C��20H
	           INT    10H
	           MOV    DX,MY8255_A
	           MOV    AL,00H
	           MOV    [LED_A],AL
	           OUT    DX,AL
	           MOV    [A_SUB],AL
	           MOV    DX,MY8255_C
	           MOV    AL,90H
	           OUT    DX,AL
	;����ʱ
	           MOV    AX,[STATE+6]
	           SUB    AX,CX
	           MOV    BL,0AH
	           DIV    BL
	           MOV    [CD],AH         	;��������λ
	           MOV    [CD+1],AL       	;������ʮλ
	           MOV    AX,[STATE+6]
	           SUB    AX,CX
	           DIV    BL
	           MOV    [CD+2],AH
	           MOV    [CD+3],AL
	           JMP    NEXT
	NEXT:      
	           INC    CX
	           MOV    [CX_SUB],CX
	RETURN:    MOV    AL, 20H
	           OUT    20H, AL         	;�жϽ�������
	           POP    DX
	           POP    CX
	           POP    BX
	           POP    AX
	           IRET

	;===========================================
	; INIT_TIME ��ʱ�����õĳ�ʼ��
	;===========================================
	INIT_TIME: 
	           PUSH   AX
	           PUSH   BX
	           PUSH   CX
	           PUSH   SI
	           XOR    CX,CX
	           MOV    [CX_SUB],CX
	           MOV    [TIME_COUNT],CX
	           MOV    AX,[GREEN]
	           MOV    BX,[YELLOW]
	           MOV    SI,OFFSET STATE
	           ADD    CX,AX
	           MOV    [SI],CX
	           ADD    CX,BX
	           MOV    [SI+2],CX
	           ADD    CX,AX
	           MOV    [SI+4],CX
	           ADD    CX,BX
	           MOV    [SI+6],CX
	           ADD    CX,AX
	           MOV    [SI+8],CX
	           XOR    AX,AX
	           MOV    [TIME_COUNT],AX
	           POP    SI
	           POP    CX
	           POP    BX
	           POP    AX
	           RET
	;===========================================
	; CCSCAN ����ɨ���ӳ���
	;===========================================
	; ԭ���� ����ȫ��������͵�ƽ
	; Ȼ���C�ڶ��� �е�ƽ
	; ���û�а������� ������Ӧ�þ�Ϊ�ߵ�ƽ
	; ��֮ ���а������� ��ʼ��ϸ�жϳ��������ĸ��������� �����жϷ����ǣ�
	; �����һ������͵�ƽ�������ң�
	; Ȼ���C�ڶ����е�ƽ ���� AND
	; �ж���һ���Ƿ�Ϊ�͵�ƽ����(����Ϊ�˼��㷽��ȡ�����е�ƽ)
	; ����ȫΪ�� Ϊ��ʼ����һ������͵�ƽ ѭ��4�μ���
	CCSCAN:    MOV    AL,00H
	           MOV    DX,MY8255_A
	           OUT    DX,AL           	; ����������� �͵�ƽ
	           MOV    DX,MY8255_C
	           IN     AL,DX           	;�������е�ƽ
		
	;ԭ��û���κμ����� 4��ȫΪ1
	;����ȡ�� ��� 0000 ���ں�����ж�
	           NOT    AL
		
	; ����û�а�������
	; 0000&1111=0
	; ���Ϊ0 ZF=1
	           AND    AL,0FH
	           RET

	;=====================================
	; MIR6 �ж�
	;=====================================
	MIR6:      
	           CLI
	           PUSH   AX
	           PUSH   BX
	           PUSH   CX
	           PUSH   DX
	           PUSH   SI
	           PUSH   DI
	           MOV    SI,OFFSET CD
	           MOV    AL,00H
	           MOV    [SI],AL         	;����ʾ����
	           MOV    [SI+1],AL
	           MOV    [SI+2],AL
	           MOV    [SI+3],AL
	           MOV    [SI+4],AL
	           MOV    [SI+5],AL

	           MOV    DI,OFFSET CD+5


	BEGIN2:    
	           CALL   DIS
	           CALL   CLEAR
	           CALL   CCSCAN
	           JNZ    INK1
	           JMP    BEGIN2
	INK1:      
	           CALL   DIS
	           CALL   DALLY
	           CALL   DALLY
	           CALL   CLEAR
	           CALL   CCSCAN
	           JNZ    INK2
	           JMP    BEGIN2
	INK2:      
	           MOV    CH,0FEH         	; FEH=1111 1110����Ӧ��ϵ��PA7 PA6..PA1 PA0 ��
	           MOV    CL,00H          	; ��ʼ�����е�ƫ���� Ϊ0
	COLUM:     
	           MOV    AL,CH
	           MOV    DX,MY8255_A
	           OUT    DX,AL
	           MOV    DX,MY8255_C
	           IN     AL,DX
	L1:        TEST   AL,01H          	;is L1?
	           JNZ    L2
	           MOV    AL,00H          	;L1
	           JMP    KCODE
	L2:        TEST   AL,02H          	;is L2?
	           JNZ    L3
	           MOV    AL,04H          	;L2
	           JMP    KCODE
	L3:        TEST   AL,04H          	;is L3?
	           JNZ    L4
	           MOV    AL,08H          	;L3
	           JMP    KCODE
	L4:        TEST   AL,08H          	;is L4?
	           JNZ    NEXT2
	           MOV    AL,0CH          	;L4
	KCODE:     ADD    AL,CL           	;�õ��ܵ�ƫ����
	           CMP    AL,0EH          	;ȡ����
	           JZ     RETURN2
	           CMP    AL,0FH          	;ȷ����
	           JZ     ENSURE_BTN
	SHOW:      CALL   PUTBUF
	           PUSH   AX
	KON:       CALL   DIS
	           CALL   CLEAR
	           CALL   CCSCAN
	           JNZ    KON
	           POP    AX
	NEXT2:     INC    CL              	; CL�൱�� ��ƫ����
	           MOV    AL,CH
	           TEST   AL,08H          	; 08H=0000 1000 ��ALΪ1111 0111 && 0000 1000 ���Ϊ0
	           JZ     KERR            	;  4����ѭ������ ��KERR
	           ROL    AL,1
	           MOV    CH,AL
	           JMP    COLUM
	KERR:      
	           JMP    BEGIN2
	RETURN2:   MOV    AL, 20H
	           OUT    20H, AL         	;�жϽ�������
	           POP    DI
	           POP    SI
	           POP    DX
	           POP    CX
	           POP    BX
	           POP    AX
	           STI
	           IRET
	ENSURE_BTN:CALL   SET_TIME
	           JMP    RETURN2

	;=============================================
	; SET_TIME ����ʱ���ӳ���
	;=============================================
	SET_TIME:  
	           PUSH   AX
	           PUSH   BX
	           PUSH   CX
	           XOR    AX,AX
	           MOV    SI,OFFSET CD

	           MOV    CX,0AH
	           MOV    AL,[SI+5]       	;ʮλ
	           MOV    BL,[SI+4]       	;��λ
	           MUL    CL
	           ADD    AL,BL
	
	           MOV    [GREEN],AX

	           MOV    AL,[SI+3]       	;ʮλ
	           MOV    BL,[SI+2]       	;��λ
	           MUL    CL
	           ADD    AL,BL
	           MOV    [YELLOW],AX
	           CALL   INIT_TIME
	           
	           MOV    AL,00H
		
	           MOV    [SI],AL         	;����ʾ����
	           MOV    [SI+1],AL
	           MOV    [SI+2],AL
	           MOV    [SI+3],AL
	           MOV    [SI+4],AL
	           MOV    [SI+5],AL
	           CALL   CLEAR
	           PUSH   CX
	           POP    BX
	           POP    AX

	           RET
			    
CODE	ENDS
		END START

