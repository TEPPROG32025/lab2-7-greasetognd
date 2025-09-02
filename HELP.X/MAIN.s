#include <xc.inc>
 
        __CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLR_OFF

; Définition des constantes de délai
DELAY_SLOW EQU 0xFF
DELAY_FAST EQU 0x30

; Variables en RAM
CBLOCK 0x20
    delay_count
ENDC

; Point d'entrée
    ORG 0x00
    GOTO START

START:
    ; Initialisation ports et registres

    ; Configurer PORTB bits 0 et 1 en entrée, bit 7 en sortie
    BSF STATUS, RP0      ; Bank 1
    MOVLW b'10000011'    ; RB7=0 (sortie), RB0 et RB1=1 (entrée), autres bits peuvent être entrée aussi
    MOVWF TRISB
    ; Activer résistances pull-up internes sur PORTB
    MOVLW b'00000111'    ; RBPU=0 (activé), RB0,1,2 pull-ups activés
    MOVWF OPTION_REG

    BCF STATUS, RP0      ; Bank 0

    ; Initialiser PORTB
    CLRF PORTB

MAIN_LOOP:
    ; Lire boutons (bits 0 et 1)
    MOVF PORTB, W
    ANDLW b'00000011'      ; Masque bits 0 et 1

    ; Si au moins un bouton appuyé (logique 0)
    BTFSS STATUS, Z        ; Test si W != 0, si aucun bouton pressé W=3 donc Z=0
    GOTO FAST_BLINK        ; Au moins un bouton appuyé

    GOTO SLOW_BLINK        ; Aucun bouton appuyé

; Blink rapide
FAST_BLINK:
    BSF PORTB, 7
    CALL DELAY_FAST_ROUTINE
    BCF PORTB, 7
    CALL DELAY_FAST_ROUTINE
    GOTO MAIN_LOOP

; Blink lent
SLOW_BLINK:
    BSF PORTB, 7
    CALL DELAY_SLOW_ROUTINE
    BCF PORTB, 7
    CALL DELAY_SLOW_ROUTINE
    GOTO MAIN_LOOP

; Sous-routine délai rapide
DELAY_FAST_ROUTINE:
    MOVLW DELAY_FAST
    MOVWF delay_count
DFR_FAST:
    NOP
    NOP
    NOP
    DECFSZ delay_count, F
    GOTO DFR_FAST
    RETURN

; Sous-routine délai lent
DELAY_SLOW_ROUTINE:
    MOVLW DELAY_SLOW
    MOVWF delay_count
DFR_SLOW:
    NOP
    NOP
    NOP
    DECFSZ delay_count, F
    GOTO DFR_SLOW
    RETURN

    END