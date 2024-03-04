;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

;...............................................................................
; Set servo
;...............................................................................
			bis.b #BIT0, &P2DIR	; output P2.0
			bis.b #BIT0, &P2SEL ; selecciona TA0.2 en vez de GPIO
			bic.w #MC0|MC1, &TA1CTL ; apaga el temporizador TA1.
			bis.w #TACLR, &TA1CTL ; limpia el temporizador TA1
			bis.w #TASSEL__ACLK, &TA1CTL ; usa ACLK (32768 Hz).
			bic.w #ID1, &TA1CTL
			bis.w #ID0, &TA1CTL
			bis.w #MC0|MC1, &TA1CTL ; cuenta hasta TA0CCR0 y 0
			bic.w #CAP, &TA1CCTL1 ; modo de comparacion
			bis.w #OUTMOD_6, &TA1CCTL1 ; Toggle/Reset mode: this gives duty cycle of
			mov.w #164, &TA1CCR0 ; 20 ms periodo
			mov.w #145, &TA1CCR1 ; compara a 143=0 grados
			bis.w #MC0|MC1, &TA1CTL ; enciende el TA1

;...............................................................................
; Set display
;...............................................................................
            MOV #0,R5 ; count register
            bis.b #BIT4	, &P3DIR ; output display A
            bis.b #BIT3	, &P3DIR ; output display B
            bis.b #BIT6	, &P1DIR ; output display C
            bis.b #BIT6	, &P6DIR ; output display D
            bis.b #BIT2	, &P3DIR ; output display E
            bis.b #BIT7	, &P2DIR ; output display F
            bis.b #BIT2	, &P4DIR ; output display G
			;display start in 0
			bic.b #BIT4, &P3OUT	; A - on
			bic.b #BIT3, &P3OUT ; B - on
			bic.b #BIT6, &P1OUT	; C - on
			bic.b #BIT6, &P6OUT	; D - on
			bic.b #BIT2, &P3OUT	; E - on
			bic.b #BIT7, &P2OUT ; F - on
			bis.b #BIT2, &P4OUT	; G - off

;...............................................................................
; Set fototransistor whith interrupts 1
;...............................................................................

			bic.b #BIT5, &P1DIR ; output
			bis.b #BIT5, &P1REN ; resistencia habilitada
			bis.b #BIT5, &P1OUT ; resistencia pull up
			bis.b #BIT5, &P1IE  ; interrupccion activa
			bic.b #BIT5, &P1IFG ; limpia la bandera de interrupccion
			bic.b #BIT5, &P1IES ; se activa con flanco de subida

			NOP

;...............................................................................
; Set fototransistor whith interrupts 2
;...............................................................................

			bic.b #BIT4, &P1DIR ; output
			bis.b #BIT4, &P1REN ; resistencia habilitada
			bis.b #BIT4, &P1OUT ; resistencia pull up
			bis.b #BIT4, &P1IE  ; interrupccion activa
			bic.b #BIT4, &P1IFG ; limpia la bandera de interrupccion
			bic.b #BIT4, &P1IES ; se activa con flanco de subida

			NOP

;...............................................................................
; Low power mode
;...............................................................................

			bis.b #LPM3|GIE,SR
			NOP

;...............................................................................
; Fuctions
;...............................................................................

PORT1_ISR:  ; P1.5
			INC.W R5 ; Incrementa en uno el contador R5
			jmp loop ; Salta a loop

PORT2_ISR:  ; P1.4
			DEC.W R5 ; Decrementa en uno el contador
			jmp loop ; Salta a loop

loop:
			bic.w #MC0|MC1, &TA0CTL	; apaga el temporizador TA0.
			bis.w #TACLR,&TA0CTL ; limpia el temporizador TA0
			bis.w #TASSEL__ACLK, &TA0CTL ; usa ACLK (32768 Hz).
			bic.w #ID0|ID1, &TA0CTL ; divide en 1
			bic.w #TAIFG, &TA0CTL ; limpia la bandera de interrupccion TA0
			bis.w #MC0, &TA0CTL ; Modo de conteo ascendente
			bis.w #TAIE, &TA0CTL ; set
			mov.w #0x13FFB, &TA0CCR0

			NOP

			bic.b #BIT5,&P1IE ; P1.5 INTERRUPTION ENABLED
			bic.b #BIT4,&P1IE ; P1.4 INTERRUPTION ENABLED
			mov.w #155, &TA1CCR1 ; servo 90°

			CMP #0,R5
			jeq cond0
			jl cond0
			CMP #1, R5
			jeq cond1
			CMP #2, R5
			jeq cond2
			CMP #3, R5
			jeq cond3
			CMP #4, R5
			jeq cond4
			CMP #5, R5
			jeq cond5
			CMP #6, R5
			jeq cond6
			CMP #7, R5
			jeq cond7
			CMP #8, R5
			jeq cond8
			CMP #9, R5
			jeq cond9
			jge cond9

cond0:
			MOV #0,R5
			bic.b #BIT4, &P3OUT ;  a on
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bic.b #BIT6, &P6OUT ;  d on
			bic.b #BIT2, &P3OUT ;  e on
			bic.b #BIT7, &P2OUT ;  f on
			bis.b #BIT2, &P4OUT ;  g off
			jmp delay

cond1:
			bis.b #BIT4, &P3OUT ;  a off
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bis.b #BIT6, &P6OUT ;  d off
			bis.b #BIT2, &P3OUT ;  e on
			bis.b #BIT7, &P2OUT ;  f on
			bis.b #BIT2, &P4OUT ;  g on
			jmp delay

cond2:
			bic.b #BIT4, &P3OUT ;  a on
			bic.b #BIT3, &P3OUT ;  b on
			bis.b #BIT6, &P1OUT ;  c off
			bic.b #BIT6, &P6OUT ;  d on
			bic.b #BIT2, &P3OUT ;  e on
			bis.b #BIT7, &P2OUT ;  f off
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay

cond3:
			bic.b #BIT4, &P3OUT ;  a on
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bic.b #BIT6, &P6OUT ;  d on
			bis.b #BIT2, &P3OUT ;  e off
			bis.b #BIT7, &P2OUT ;  f off
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay


cond4:
			bis.b #BIT4, &P3OUT ;  a off
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bis.b #BIT6, &P6OUT ;  d off
			bis.b #BIT2, &P3OUT ;  e off
			bic.b #BIT7, &P2OUT ;  f on
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay

cond5:

			bic.b #BIT4, &P3OUT ;  a on
			bis.b #BIT3, &P3OUT ;  b off
			bic.b #BIT6, &P1OUT ;  c on
			bic.b #BIT6, &P6OUT ;  d on
			bis.b #BIT2, &P3OUT ;  e off
			bic.b #BIT7, &P2OUT ;  f on
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay
cond6:
			bic.b #BIT4, &P3OUT ;  a on
			bis.b #BIT3, &P3OUT ;  b off
			bic.b #BIT6, &P1OUT ;  c on
			bic.b #BIT6, &P6OUT ;  d on
			bic.b #BIT2, &P3OUT ;  e on
			bic.b #BIT7, &P2OUT ;  f on
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay
cond7:
			bic.b #BIT4, &P3OUT ;  a on
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bis.b #BIT6, &P6OUT ;  d off
			bis.b #BIT2, &P3OUT ;  e on
			bis.b #BIT7, &P2OUT ;  f off
			bis.b #BIT2, &P4OUT ;  g off
			jmp delay

cond8:
			bic.b #BIT4, &P3OUT ;  a on
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bic.b #BIT6, &P6OUT ;  d on
			bic.b #BIT2, &P3OUT ;  e on
			bic.b #BIT7, &P2OUT ;  f on
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay

cond9:
			MOV #9,R5
			bic.b #BIT4, &P3OUT ;  a on
			bic.b #BIT3, &P3OUT ;  b on
			bic.b #BIT6, &P1OUT ;  c on
			bic.b #BIT6, &P6OUT ;  d on
			bis.b #BIT2, &P3OUT ;  e off
			bic.b #BIT7, &P2OUT ;  f on
			bic.b #BIT2, &P4OUT ;  g on
			jmp delay

delay:
			mov.w #0x4E200, &TA0CCR0 ;contador 5 seg

TA0_ISR:
			cmp.w #TA0IV_TAIFG, &TA0IV ;compara si existe interrupcion
			jnz not_flag ; si no está a cero
			mov.w #145 , &TA1CCR1 ; servomotor a 0°

			bis.b #BIT5,&P1IE ; activa la interrupccion P1.5
			bis.b #BIT4,&P1IE ; activa la interrupccion P1.4
			bic.b #BIT5,&P1IFG ; limpiar la bandera P1.5
			bic.b #BIT4,&P1IFG ; limpiar la bandera P1.4

			reti

not_flag:
			bic.w #TAIFG,&TA0CTL ; clear flag
			reti

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
			.sect ".int47"
            .short PORT1_ISR
			.sect ".int42"
			.short PORT2_ISR
			.sect ".int52"
			.short TA0_ISR
