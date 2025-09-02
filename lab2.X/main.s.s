 LIST P=16F88
    #include <p16f88.inc>

    __CONFIG _CP_OFF & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _PWRTE_ON

; Définition des constantes
DELAY_SLOW EQU 0xFF
DELAY_FAST EQU 0x30

; Registres temporaires
CBLOCK 0x20
    delay_count
    i
ENDC

; Initialisation
    ORG 0x00
    GOTO START

; Routine de démarrage
START:
    ; Configurer les ports
    BSF STATUS, RP0       ; Bank 1
    MOVLW 0x03           ; PORTB bits 0 et 1 en entrée (boutons), bit 7 en sortie (LED)
    MOVWF TRISB
    BCF STATUS, RP0       ; Bank 0

    ; Initialiser PORTB
    CLRF PORTB

MAIN_LOOP:
    ; Lire les boutons (bits 0 et 1)
    MOVF PORTB, W
    ANDLW 0x03           ; masque bits 0 et 1

    ; Si bouton appuyé (bits 0 ou 1 à 0 car pull-up activé par défaut)
    BTFSC STATUS, Z       ; si W == 0 alors boutons appuyés (car pull-up = 1, bouton = 0)
    GOTO FAST_BLINK
    GOTO SLOW_BLINK

FAST_BLINK:
    ; DEL ON
    BSF PORTB, 7
    CALL DELAY_FAST_ROUTINE
    ; DEL OFF
    BCF PORTB, 7
    CALL DELAY_FAST_ROUTINE
    GOTO MAIN_LOOP

SLOW_BLINK:
    ; DEL ON
    BSF PORTB, 7
    CALL DELAY_SLOW_ROUTINE
    ; DEL OFF
    BCF PORTB, 7
    CALL DELAY_SLOW_ROUTINE
    GOTO MAIN_LOOP

; Sous-routines de délai
DELAY_FAST_ROUTINE:
    MOVLW DELAY_FAST
    MOVWF delay_count
DFR1:
    NOP
    NOP
    NOP
    DECFSZ delay_count, F
    GOTO DFR1
    RETURN

DELAY_SLOW_ROUTINE:
    MOVLW DELAY_SLOW
    MOVWF delay_count
DFR2:
    NOP
    NOP
    NOP
    DECFSZ delay_count, F
    GOTO DFR2
    RETURN

    END
   


