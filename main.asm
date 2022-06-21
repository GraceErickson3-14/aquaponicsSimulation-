;
; Project: Aquaponic System
;
; Authors: A.Patterson, G.Erickson, A.Guerra Delgado
; Created: 12/9/2021 7:55:21 PM


; Vector Table 
; ------------------------------------------------------------

.org 0x00                ;reset
     jmp main

.org INT0addr            ;External Interrupt Request 0
     jmp LED_T

.org 0x001c
	jmp MOTOR

.org INT_VECTORS_SIZE    ;end of v-table


; enable all interrupts
     SEI

; enable Timer 0 interrupt stuff

     LDI R16, 0b00000010
     STS TIMSK0, R16  ; the interrupt
     LDI R16, 20
     STS OCR0A, R16   ; the interrupt trigger

Main:

Start:
; turn off on board light
 	LDI R17, 0b00100000
 	STS DDRB, R17
 	LDI R17, 0
 	STS PORTB, R17

; config LED
 	LDI R16, 0b00100000
 	OUT DDRC, r16
 	LDI R16, 0
 	OUT PORTC, R16


; Configure I/O for Photo Resistor

     cbi  PORTD,PD2      ;Photo resistor to input (INT0)
     cbi  PORTD,PD2      ;Photo resistor set to high impedence

; Configure External Interrupt

     ldi  R21, 1   ;Enable INT0 on D2
     sts  EIMSK,R21

     ldi  R21, 1 ;INT0 any edge trigger
     sts  EICRA, R21

     LDI R20, 0


; enable Timer 0 interrupt stuff

     LDI R16, 0b00000010
     STS TIMSK0, R16  ; the interrupt
     LDI R16, 20
     STS OCR0A, R16   ; the interrupt trigger


; loop waiting for 24hrs for motor


MLOOP:
     LDI R17, 200

OLOOP:
     LDI R18, 103

ILOOP:
     STS TCCR1A, R20     ; Normal Mode
     STS TCCR1C, R20     ; No Ouput Compare

TIMER:
     LDI R16, 0b00000101 ; Normal Mode and CLK / 1024 for timer 1
     STS TCCR1B, R16;
     SBIS TIFR1, TOV1
     RJMP TIMER
     LDI R16, 1          ; Reset mask TOV1
     STS TCCR1B, R20     ; Turn clock off
     STS TIFR1, R16      ; reset TOV1

     DEC R18
     BRNE ILOOP
     DEC R17
     BRNE OLOOP

; method to enable an interrupt for the motor

M_INT:
     LDI R16, 2
     STS TCCR0A, r16    ; CTC Mode
     LDI R16, 1
     STS TCCR0B, R16  ; Select Clock
     RJMP MLOOP


LED_T:
IN R25, PORTC
LDI R26, 0b00100000
EOR R25, R26
OUT PORTC, R25  	;———— code to toggle LED

RETI

MOTOR:

 	LDI R29, 5
     LDI R16, 0b00001111
    	OUT DDRD, R16            ; bits 0-3 of port b output
    	LDI R16, 0b00000110

INL:
 	LDI R28, 255
LOAD:    
 	OUT PORTB, R16	          ; loading first step of sequence
     LSR R16       	          ; shifting sequence
     BRCC DELAY
     ORI R16, 0b00001000      ; accounting for carry 

DELAY:  
 	LDI R30, 150
HOT:    
 	LDI R31, 150
COOL:   
 	NOP
     DEC R31
     BRNE COOL
     DEC R30
     BRNE HOT
 	DEC R28
 	BRNE LOAD
 	DEC R29
 	BRNE INL

 	LDI R17, 0b00100000
 	STS DDRB, R17
 	LDI R17, 0
 	STS PORTB, R17

	RETI

end_main:
     rjmp end_main

