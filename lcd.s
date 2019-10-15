; Sistemas Microcontrolados - UTFPR 2019/1
; Laboratório 02 - Cofre Eletrônico
; Matheus Bigarelli e Victor Belinello

; -------------------------------------------------------------------------------
    THUMB                        ; Instruções do tipo Thumb-2

	AREA STRINGS, DATA, READONLY, ALIGN=2
	
OPEN_STR DCB "Cofre aberto, digite nova senha para fechar o cofre",0
OPENNING_STR DCB "Cofre abrindo",0
CLOSED_STR DCB "Cofre fechado",0
CLOSING_STR DCB "Cofre fechando",0  
TABUADA_STR DCB "Tabuada do "



; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
	AREA    |.text|, CODE, READONLY, ALIGN=2

    IMPORT SysTick_Wait1ms
    IMPORT SysTick_Wait1us   
    IMPORT PortM_Output
    IMPORT PortK_Output
        
    EXPORT LCD_Init
    EXPORT LCD_Cmd
    EXPORT LCD_Data
    EXPORT LCD_Print
		
	EXPORT OPEN_STR
	EXPORT OPENNING_STR
	EXPORT CLOSED_STR
	EXPORT CLOSING_STR
	
	EXPORT LCD_Write_Tabuada

  


; -------------------------------------------------------------------------------
; Função LCD_Init
; Parâmetro de entrada:
; Parâmetro de saída:
LCD_Init
	PUSH {LR}

	MOV R0, #0x38
	BL LCD_Cmd
	MOV R0, #0x06
	BL LCD_Cmd
	MOV R0, #0x0E
	BL LCD_Cmd
	MOV R0, #0x01
	BL LCD_Cmd

	POP {LR}
	BX LR

; -------------------------------------------------------------------------------
; Função LCD_Cmd
; Parâmetro de entrada: R0
; Parâmetro de saída:
LCD_Cmd
    PUSH {LR}
    PUSH {R0}
        
    MOV R0, #0x00       ;RS=RW=E=0
    BL PortM_Output
    
    POP {R0}            ;Recupera o comando em R0
    PUSH {R0}           ;Salva novamente para uso posterior
    BL PortK_Output     ;Escreve comando no LCD
    
    
    MOV R0, #2_100      ;Enable 
    BL PortM_Output
    
    MOV R0, #40          ;Pulse
    BL SysTick_Wait1us
    
    POP {R0}            ;Recupera comando em R0
    CMP R0, #0x02       ;Verifica se o comando é um dos que requer 1,64ms de delay
    BGT Disable
    
    MOV R0, #1640        ;Pulse
    BL SysTick_Wait1us
      
Disable
    MOV R0, #0x00       ;Disable
    BL PortM_Output
    POP {LR}
    BX LR

LCD_Write_Tabuada
	PUSH {LR}
    PUSH {R0}
    CMP R0, #0
	BEQ End_LCD
	
	MOV R0, #0x02
	BL LCD_Cmd
	
	LDR R1, =TABUADA_STR
	BL LCD_Print
	
	POP {R0}
	PUSH {R0}
	BL LCD_Data
	
	MOV R0, #0xCA
	BL LCD_Cmd
	
	POP {R0}
	PUSH {R0}
	BL LCD_Data
	
	MOV R0, #0x20
	BL LCD_Data
	
	
	MOV R0, #0x30
	BL LCD_Data
	
	
	
	
; -------------------------------------------------------------------------------
; Função LCD_Data
; Parâmetro de entrada: R0
; Parâmetro de saída:
LCD_Data
    PUSH {LR}
    PUSH {R0}
    CMP R0, #0
	BEQ End_LCD
	
    MOV R0, #2_001      ;RS=1, RW=E=0
    BL PortM_Output
    
    POP {R0}
    BL PortK_Output
    PUSH {R0}
    MOV R0, #2_101      ;RS=E=1, RW=0
    BL PortM_Output
    
    MOV R0, #40
    BL SysTick_Wait1us
    
    MOV R0, #2_001       ;Disable
    BL PortM_Output


	

End_LCD
	POP {R0}
    POP {LR}
    BX LR

LCD_Print_Closed_Msg
	PUSH {LR}
	LDR R1, =CLOSED_STR
	BL LCD_Print
	POP {LR}
	BX LR

; -------------------------------------------------------------------------------
; Função LCD_Print
; Parâmetro de entrada: R1 (endereço da string)
; Parâmetro de saída:
LCD_Print
		PUSH {LR}
ReadString
		LDRB R0, [R1], #1
		CMP R0, #0x0
		BNE Print
		B Return
Print  
		PUSH {R1}
		BL LCD_Data 		;Prints R0
		POP {R1}
		B ReadString
		
Return		
		POP {LR}
		BX LR		
		ALIGN
		END