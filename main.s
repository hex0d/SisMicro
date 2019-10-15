; Sistemas Microcontrolados - UTFPR 2019/1
; Laborat�rio 02 - Cofre Eletr�nico
; Matheus Bigarelli e Victor Belinello

; -------------------------------------------------------------------------------
    THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
		
        
        
; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
    AREA    |.text|, CODE, READONLY, ALIGN=2
 
    EXPORT Start

    IMPORT PLL_Init
    IMPORT SysTick_Init
	IMPORT SysTick_Wait1ms	
    IMPORT GPIO_Init
    IMPORT LCD_Init
    IMPORT LCD_Data
    IMPORT LCD_Print
		
	IMPORT OPEN_STR
	IMPORT OPENNING_STR
	IMPORT CLOSED_STR
	IMPORT CLOSING_STR	

	IMPORT Scan_Keyboard
	
	IMPORT LCD_Write_Tabuada
		
Start
	BL SysTick_Init
    BL PLL_Init
    BL GPIO_Init
	BL LCD_Init
    
MainLoop	
	BL Scan_Keyboard
	BL LCD_Write_Tabuada
	MOV R0, #100
	BL SysTick_Wait1ms
	B MainLoop
	NOP
	
    ALIGN
	END