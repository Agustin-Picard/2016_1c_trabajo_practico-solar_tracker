;*****************************************************
;* 	Programa PWM PORTB
;*
;*  Created: 27/05/2016
;*  Autor: Joaqu�n Ulloa
;*	
;*	f_outPWM = f_clkIO / (prescaler * 256)
;*	Configuracion Fast Pwm
;*	
;***************************************************** 

.include "m328Pdef.inc"   	;Incluye los nombres de los registros del micro
.include "avr_macros.inc"	;Incluye los macros
.listmac					;Permite que se expandan las macros en el listado
;***************************************************** 
.DSEG						;Se abre un segmento de datos para definir variables
.DEF	PWM_DATA 	= R16
.DEF	PWM_AUX		= R17

.EQU	OC1A =	PB1
.EQU	OC1B =	PB2
.EQU	OC0A =	PD6
.EQU	OC0B =	PD5

.EQU	PWM_DC = 30		;Duty cicle {0,255}
.CSEG
;***************************************************** 
.ORG 0x0000				;se setean los registros de interrupciones
RJMP SETUP_PWM

;PRUEBO CON PB1 [OC1A]

SETUP_PWM:
;Se inicializa el stack pointer
	LDI PWM_DATA,LOW(RAMEND)
	OUT SPL,PWM_DATA
	LDI	PWM_DATA,HIGH(RAMEND)
	OUT SPH,PWM_DATA
;Se inicializan como salida los pines de PWM
	INPUT PWM_DATA,DDRB
	ANDI PWM_DATA (~(0x06))	;Mascara para tocar solo B1 Y B2
	ORI PWM_DATA,((1<<DDB1)|(1<<DDB2))
	OUTPUT DDRB,PWM_DATA
;	SBI DDRB,1				;(PCINT1/OC1A) PB1 
;	SBI DDRB,2				;(PCINT2/OC1B/SS) PB2
;	output PWM_DATA,DDRB
	LDI PWM_AUX,((1<<OC0A)|(1<<OC0B))
	OUTPUT DDRD,PWM_AUX	
;	SBI DDRD,5				;(PCINT21/OC0B/T1) PD5
;	SBI DDRD,6				;(PCINT22/OC0A/AIN0) PD6
;	output PWM_DATA,DDRB

;Se inicializan como Fast PWM y non-inverting mode
	;Fast PWM: WGM02=0 (por defecto), WGM01=1 y WGM00=1
	;Non-inverting mode: COM0A1=1 y COM0A0=0
	;Descripcion de registros en seccion 15.9 (pag 106-112)
	INPUT PWM_DATA,TCCR0A	;Timer/counter control register A
	ANDI PWM_DATA,(~(0xF3))	;Mascara para no tocar bits 2 y 3

	ORI PWM_DATA,((1<<WGM01)|(1<<WGM00)|(1<<COM0A1)|(0<<COM0A0)|(1<<COM0B1)|(0<<COM0B0))	;fast PWM, non-inverting
	OUTPUT TCCR0A,PWM_DATA
;Se inicializa el prescaler del PWM
	INPUT PWM_DATA,TCCR0B	;Timer/counter control register B
	;hacer mascara de forma tal que los bits 0, 1, 2 queden en 0
	ANDI PWM_DATA,(~0x07)	;Mascara para no tocar bits 3 a 7
	ORI PWM_DATA,((0<<CS00)|(1<<CS01)|(0<<CS02))	;Prescaler = 8
	OUTPUT TCCR0B,PWM_DATA

;hasta aca se configuro el pwm para el timer de 8 bits, falta el de 16m

/*
MAIN:
	LDI PWM_DATA,PWM_DC	
	OUTPUT OCR0A,PWM_DATA	
	
	RJMP MAIN
*/
	LDI PWM_DATA,0x00	
MAIN:
	OUTPUT OCR0A,PWM_DATA	
	INC PWM_DATA
	RCALL DELAY
	CPI PWM_DATA,30
	BRSH RESETEO
RJMP MAIN

RESETEO:
	CLR PWM_DATA
	RJMP MAIN

DELAY:
; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
;
; Delay 80 000 cycles
; 10ms at 8.0 MHz

    ldi  r18, 2
    ldi  r19, 56
    ldi  r20, 174
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1

RET				