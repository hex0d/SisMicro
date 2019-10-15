; Sistemas Microcontrolados - UTFPR 2019/1
; Laborat�rio 02 - Cofre Eletr�nico
; Matheus Bigarelli e Victor Belinello

; -------------------------------------------------------------------------------
    THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------

; C�digo hexadecimal correspondente de cada tecla

; --------------------------------------------------------------------------------

	AREA KEYS, DATA, READONLY, ALIGN=2
		
KEY_1		DCW		0x31
KEY_2		DCW		0x32
KEY_3		DCW		0x33	
KEY_A 		DCW		0x41

KEY_4		DCW		0x34
KEY_5		DCW		0x35
KEY_6		DCW		0x36
KEY_B 		DCW		0x42

KEY_7		DCW		0x37
KEY_8		DCW		0x38
KEY_9		DCW		0x39
KEY_C 		DCW		0x43

KEY_AST 	DCW		0x2A
KEY_0		DCW		0x30
KEY_HASH 	DCW		0x23
KEY_D 		DCW		0x44




   	AREA PASSWORD, DATA, READWRITE, ALIGN=2

MASTER_PWD DCB "1111",0
USER_PWD SPACE 5     
        
; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
    AREA    |.text|, CODE, READONLY, ALIGN=2
        
		EXPORT Scan_Keyboard
		IMPORT PortM_Output
		IMPORT PortL_Input
			
; -------------------------------------------------------------------------------
; Fun��o Read_PortL
; Le entrada usando t�cnica de debouncing por software.
; Par�metro de entrada: 
; Par�metro de sa�da: R0
Read_PortL	   
	PUSH {LR}

	BL PortL_Input		;Le entrada
	MOV R1, R0			;ValorTemp = ValorAtual	
	MOV R2, #20			;Timer	

CheckLoop
	CMP R2, #0
	BGT Loop			;R2 > 0
	B Return 			;R2 <=0

Loop
	PUSH {R1}
	BL PortL_Input		;Le novamento o valor da entrada
	POP {R1}
	CMP R1, R0			;Compara ValorTemp e ValorAtual
	BNE Changed
	
	SUB R2, #1			;N�o mudou valor de entrada, diminui timer
	B CheckLoop
	
Changed	
	MOV R1, R0			;Atualiza ValorTemp = ValorAtual	
	MOV R2, #20			;Reseta Timer	
	B CheckLoop
	
Return
	MOV R0, R1			;ValorAtual = ValorTemp
	
	POP {LR}
	BX LR
	

; -------------------------------------------------------------------------------
; Fun��o Scan_Keyboard
; Par�metro de entrada: 
; Par�metro de sa�da: R0
Scan_Keyboard
	PUSH {LR}
	
	MOV R0, #2_1110
	BL Scan_Column			;R1 cont�m a linha lida, Se for zero nenhuma linha foi lida, se for 1 primeira linha ...
	;R0 coluna, R1 linha
	BL Find_Key				;R0 cont�m o c�digo hex da tecla, zero se nenhuma pressionada
	CMP R0, #0
	BNE End_Scan
	
	MOV R0, #2_1101
	BL Scan_Column
	BL Find_Key				;R0 cont�m o c�digo hex da tecla, zero se nenhuma pressionada
	CMP R0, #0
	BNE End_Scan
	
	MOV R0, #2_1011
	BL Scan_Column
	BL Find_Key				;R0 cont�m o c�digo hex da tecla, zero se nenhuma pressionada
	CMP R0, #0
	BNE End_Scan
	
	MOV R0, #2_0111
	BL Scan_Column
	BL Find_Key				;R0 cont�m o c�digo hex da tecla, zero se nenhuma pressionada
	CMP R0, #0
	BNE End_Scan
	
End_Scan 
	POP {LR}
	BX LR
	
; -------------------------------------------------------------------------------
; Fun��o Scan_Column
; Par�metro de entrada: R0
; Par�metro de sa�da: R0, R1
Scan_Column
	PUSH {LR}
	PUSH {R0}
	
	LSL R0, #4
	BL PortM_Output
	BL Read_PortL
	
	BL Convert_One_Hot	;Converte 1110 -> 0, 1101 -> 1 ... 1111 -> 4
	MOV R1, R0
	
	POP {R0}
	BL Convert_One_Hot
	POP {LR}
	BX LR


; -------------------------------------------------------------------------------
; Fun��o Convert_One_Hot
; Par�metro de entrada: R0
; Par�metro de sa�da: R0
Convert_One_Hot
	PUSH {LR}
	CMP R0, #2_1110
	BEQ Zero
	CMP R0, #2_1101
	BEQ One
	CMP R0, #2_1011
	BEQ Two
	CMP R0, #2_0111
	BEQ Three
	B Other
Zero
	MOV R0, #0
	B return
One
	MOV R0, #1
	B return
Two 
	MOV R0, #2
	B return
Three
	MOV R0, #3
	B return

Other
	MOV R0, #4		;Qualquer outro caso 
	B return
	
return
	POP {LR}
	BX LR


; -------------------------------------------------------------------------------
; Fun��o Find_Key
; Par�metro de entrada: R0, R1
; Par�metro de sa�da: R0 (C�digo hexadecimal da tecla correspondente)
Find_Key	
	PUSH {LR}
	CMP R1, #4			;Nenhuma linha lida, ou invalido
	BEQ ReturnZero
	
	MOV R2, #4
	MUL R3, R1, R2
	ADD R3, R0			;Numero de indices a pular
	MOV R2, #2
	MUL R3, R2			;Quantidade de bytes a pular

	
	LDR R2, =KEY_1		;Primeiro endere�o da matriz
	ADD R2, R3			;Move a partir do endere�o inicial (endere�amento matricial)
	LDRH R0, [R2]	
	B ReturnKey
	
ReturnZero
	MOV R0, #0

ReturnKey
	POP {LR}
	BX LR
	
	
	ALIGN
	END