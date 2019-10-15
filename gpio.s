; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
; ========================
; ========================
; Definições dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Definições dos Ports
; PORT J (Chave)
GPIO_PORTJ_AHB_LOCK_R    	EQU     0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU     0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU     0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU     0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU     0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU     0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU     0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU     0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU     0x400603FC
GPIO_PORTJ               	EQU     2_000000100000000
GPIO_PORTJ_BITS             EQU     2_00000001  ;Bits usados no PortJ


; PORT K (LCD)
GPIO_PORTK_LOCK_R       	EQU	    0x40061520
GPIO_PORTK_CR_R         	EQU	    0x40061524
GPIO_PORTK_AMSEL_R      	EQU     0x40061528
GPIO_PORTK_PCTL_R       	EQU     0x4006152C
GPIO_PORTK_DIR_R        	EQU     0x40061400
GPIO_PORTK_AFSEL_R      	EQU     0x40061420
GPIO_PORTK_DEN_R        	EQU     0x4006151C
GPIO_PORTK_PUR_R        	EQU     0x40061510
GPIO_PORTK_DATA_R       	EQU     0x400613FC
GPIO_PORTK               	EQU     2_000001000000000
GPIO_PORTK_BITS             EQU     2_11111111  ;Bits usados no PortK 
 
 
; PORT L (Teclado)
GPIO_PORTL_LOCK_R           EQU     0x40062520
GPIO_PORTL_CR_R             EQU     0x40062524
GPIO_PORTL_AMSEL_R          EQU     0x40062528
GPIO_PORTL_PCTL_R           EQU     0x4006252C
GPIO_PORTL_DIR_R            EQU     0x40062400
GPIO_PORTL_AFSEL_R          EQU     0x40062420
GPIO_PORTL_DEN_R            EQU     0x4006251C
GPIO_PORTL_PUR_R            EQU     0x40062510
GPIO_PORTL_DATA_R           EQU     0x400623FC
GPIO_PORTL               	EQU     2_000010000000000
GPIO_PORTL_BITS             EQU     2_00001111  ;Bits usados no PortL 

; PORT M(LCD + Teclado)
GPIO_PORTM_LOCK_R           EQU     0x40063520
GPIO_PORTM_CR_R             EQU     0x40063524
GPIO_PORTM_AMSEL_R          EQU     0x40063528
GPIO_PORTM_PCTL_R           EQU     0x4006352C
GPIO_PORTM_DIR_R            EQU     0x40063400
GPIO_PORTM_AFSEL_R          EQU     0x40063420
GPIO_PORTM_DEN_R            EQU     0x4006351C
GPIO_PORTM_PUR_R            EQU     0x40063510
GPIO_PORTM_DATA_R           EQU     0x400633FC
GPIO_PORTM               	EQU     2_000100000000000
GPIO_PORTM_BITS             EQU     2_11110111  ;Bits usados no PortM 

GPIO_ALL_PORTS              EQU         2_111100000000

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2
            
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
        EXPORT PortK_Output
        EXPORT PortM_Output
        EXPORT PortL_Input
        EXPORT PortJ_Input    
            
;--------------------------------------------------------------------------------
; Função GPIO_Init
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
GPIO_Init
;=====================
; ****************************************
; Escrever função de inicialização dos GPIO
; Inicializar as portas
; ****************************************
            LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endereço do registrador RCGCGPIO
            MOV		R1, #GPIO_ALL_PORTS             ;Seta os bits da portas usadas
            STR     R1, [R0]						;Move para a memória os bits das portas no endereço do RCGCGPIO
    
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;Lê da memória o conteúdo do endereço do registrador
			MOV     R2, #GPIO_ALL_PORTS             ;Seta os bits correspondentes às portas para fazer a comparação
            CMP     R1, R2							;CMP de R1 com R2
            BNE     EsperaGPIO					    ;Se o flag Z=1(R1=R2), volta para o laço. Senão continua executando


;InputOrOutput             
            LDR     R0, =GPIO_PORTK_DIR_R
            MOV     R1, #GPIO_PORTK_BITS            ;Ativa o Port como saída
            STR     R1, [R0]
            
            LDR     R0, =GPIO_PORTL_DIR_R           
            MOV     R1, #2_0000                     ;Ativa PL0,PL1,PL2,PL3 como entrada(teclado)
            STR     R1, [R0]
            
            LDR     R0, =GPIO_PORTM_DIR_R
            MOV     R1, #GPIO_PORTM_BITS            ;Ativa o Port como saída
            STR     R1, [R0]
            
            LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endereço do DIR para o Port
            MOV     R1, #0x0               		
            STR     R1, [R0]		
            
;EnableIO 
            LDR     R0, =GPIO_PORTK_DEN_R
            MOV     R1, #GPIO_PORTK_BITS            
            STR     R1, [R0]
            
            LDR     R0, =GPIO_PORTL_DEN_R
            MOV     R1, #GPIO_PORTL_BITS            
            STR     R1, [R0]
            
            LDR     R0, =GPIO_PORTM_DEN_R
            MOV     R1, #GPIO_PORTM_BITS            
            STR     R1, [R0]
            
            LDR     R0, =GPIO_PORTJ_AHB_DEN_R		
            MOV     R1, #GPIO_PORTJ_BITS       		;Coloca no registrador os bits que serão usados pelo Port
            STR     R1, [R0]	
            
;EnableResistor
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R	    ;Carrega o endereço do PUR para a porta J
			MOV     R1, #GPIO_PORTJ_BITS		    ;Habilitar funcionalidade digital de resistor de pull-up nos bits utilisado por J
            STR     R1, [R0]

			LDR     R0, =GPIO_PORTL_PUR_R	    
			MOV     R1, #GPIO_PORTL_BITS		    
            STR     R1, [R0]
            
            BX LR

; -------------------------------------------------------------------------------
; Função PortK_Output
; Parâmetro de entrada: R0 
; Parâmetro de saída: Não tem
PortK_Output
	LDR	R1, =GPIO_PORTK_DATA_R		        ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #GPIO_PORTK_BITS                ;Primeiro limpamos o bit do lido da porta
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta K 
	BX LR	
    
; -------------------------------------------------------------------------------
; Função PortM_Output
; Parâmetro de entrada: R0 
; Parâmetro de saída: Não tem
PortM_Output
	LDR	R1, =GPIO_PORTM_DATA_R		        ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #GPIO_PORTM_BITS                ;Primeiro limpamos o bit do lido da porta
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta M 
	BX LR

; -------------------------------------------------------------------------------
; Função PortL_Input
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
PortL_Input
	LDR	R1, =GPIO_PORTL_DATA_R		        ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos 
    AND R0, R0, #2_1111                     ;Apenas os 4 LSB da porta são de saída
	BX LR


; -------------------------------------------------------------------------------
; Função PortJ_Input
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
PortJ_Input
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos 
	BX LR									;Retorno


    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo