#include <xc.inc>
 
    LIST P=16F88

    CONFIG WDTE = OFF
    CONFIG PWRTE = ON
    CONFIG MCLRE = ON
    CONFIG BOREN = ON
    CONFIG LVP = OFF


; D�finition des alias pour ports
#define SW1 PORTB,6
#define SW2 PORTB,7
#define SW3 PORTA,7
#define LED1 PORTB,3

; Variables en RAM
    COUNT1 EQU 0x20
    COUNT2 EQU 0x20
    COUNT3 EQU 0x20 
    
; Point d'entr�e
    ORG 0x000
    GOTO main

; Routine d'initialisation du PIC
InitPic:
    ; Bank 1
    BANKSEL(ANSEL)
    CLRF ANSEL             ; D�sactive les entr�es analogiques
    MOVLW 10000000B      ; RA7 en entr�e (SW3), les autres RA en entr�e
    MOVWF TRISA
    MOVLW 11000111B      ; RB7, RB6, RB2, RB1, RB0 en entr�e, RB3 (LED) en sortie
    MOVWF TRISB
    

    ; Activer r�sistances pull-up internes sur PORTB (option_reg bit 7 = 0 pour activer)
    MOVLW 00000111B      ; Pull-ups activ�s sur RB0, RB1, RB2 (optionnel)
    MOVWF OPTION_REG

    CLRF PORTA             ; Nettoyer port A
    CLRF PORTB             ; Nettoyer port B

    RETURN

; Main program
main:
    CALL InitPic

MainLoop:
    ; Lire boutons
    MOVF PORTB, W
    ANDLW 11000000B       ; Masquer RB7 et RB6
    IORWF PORTA, W        ; OR avec RA (pour RA7)
    BTFSS STATUS,2   ; Si au moins un bit � 0 (bouton appuy�), on saute
    GOTO FastBlink

    ; Aucun bouton appuy�
SlowBlink:
    BSF LED1
    CALL Delay_1s
    BCF LED1
    CALL Delay_1s
    GOTO MainLoop

; Bouton appuy�
FastBlink:
    BSF LED1
    CALL Delay_100ms
    BCF LED1
    CALL Delay_100ms
    GOTO MainLoop

; Routine d�lai 1s (approximatif, � ajuster selon oscillateur)
Delay_1s:
    MOVLW 8
    MOVWF COUNT1
D1_LOOP1:
    MOVLW 249
    MOVWF COUNT2
D1_LOOP2:
    MOVLW 250
    MOVWF COUNT3
D1_LOOP3:
    NOP
    DECFSZ COUNT3, F
    GOTO D1_LOOP3
    DECFSZ COUNT2, F
    GOTO D1_LOOP2
    DECFSZ COUNT1, F
    GOTO D1_LOOP1
    RETURN

; Routine d�lai 100ms (approximatif)
Delay_100ms:
    MOVLW 1
    MOVWF COUNT1
D100_LOOP1:
    MOVLW 249
    MOVWF COUNT2
D100_LOOP2:
    MOVLW 250
    MOVWF COUNT3
D100_LOOP3:
    NOP
    DECFSZ COUNT3, F
    GOTO D100_LOOP3
    DECFSZ COUNT2, F
    GOTO D100_LOOP2
    DECFSZ COUNT1, F
    GOTO D100_LOOP1
    RETURN

    END