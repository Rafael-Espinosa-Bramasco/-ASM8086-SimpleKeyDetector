; Simple key detector
; made in Assembly 8086
; by Rafael Espinosa

.MODEL SMALL

DATA SEGMENT BYTE COMMON 'DATA'
    ; To store user input
    USER_IN DB ' '

    ; System lines
    USER_LABEL DB 'Insert a char!!!',10,13,'...',10,13,'$'
    NEW_LINE DB 10,13,'$'

    ; Conditional lines
    USER_CHAR_MSG DB 'You entered the character ','$'
    USER_CHAR_CODE DB 'Char code: ','$'
DATA ENDS

STACK SEGMENT PAR STACK 'STACK'
    DW 100H DUP(0FFFFH)
STACK ENDS

; Macros
CL_REGS MACRO
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR DX,DX
ENDM

CODE SEGMENT PAGE PUBLIC 'CODE'
    ; Assume section
    ASSUME DS:DATA, CS:CODE, SS:STACK, ES:DATA

    ; Initialize data segment
    LEA AX,DATA
    MOV DS,AX
    MOV ES,AX

    MAIN PROC NEAR
        MAIN_LOOP:
            ; Show action to do from user
            MOV AH,09H
            LEA DX,USER_LABEL
            INT 21H

            ; Read user input
            MOV AH,07H
            INT 21H

            ; It is exit?
            CMP AL,03H
            JE EXIT

            ; Save user input
            MOV USER_IN,AL

            ; Show message 2 for user prompt
            MOV AH,09H
            LEA DX,USER_CHAR_MSG
            INT 21H

            ; Show char entered
            MOV AH,02H
            MOV DL,USER_IN
            INT 21H

            ; New Line
            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            ; Show message 3 for user prompt
            MOV AH,09H
            LEA DX,USER_CHAR_CODE
            INT 21H

            ; Char code
            CL_REGS
            MOV AL,USER_IN
            MOV BL,10

            CHAR_DIV: 
                CMP AL,10
                JB FINISH    
                XOR AH,AH
                DIV BL 
                XOR DX,DX
                MOV DL,AH
                PUSH DX
                INC CX
                
                CMP AL,0
                JNE CHAR_DIV
                JMP PROCESS
                
            FINISH:
                XOR DX,DX
                MOV DL,AL
                PUSH DX
                INC CX

            PROCESS:
                XOR AX,AX
                XOR DL,DL
                POP DX
                ADD DX,48
                MOV AH,02H
                INT 21H
                LOOP PROCESS
            
            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            JMP MAIN

            EXIT:
                MOV AX,0000H
                INT 21H

        RET
    MAIN ENDP

    END
CODE ENDS