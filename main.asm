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
    CNTRL_C_MSG DB 'This character is used to abort execution, BYE!','$'

    ALNUM_MSG DB 09,'It is an alpha-numeric character','$'
    ALPHA_MSG DB 09,'It is an alpha character','$'
    ASCII_MSG DB 09,'It is an ascii character (value of char between 0 and 127)','$'
    CNTRL_MSG DB 09,'It is a control character','$'
    DIGIT_MSG DB 09,'It is a digit character','$'
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

            ; Types of char
            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H
            
            CALL CHAR_TYPES

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H
            ; End types of char

            ; It is exit?
            CL_REGS
            MOV AL,USER_IN
            CMP AL,03H
            JE EXIT

            JMP MAIN

            EXIT:
                MOV AH,09H
                LEA DX,CNTRL_C_MSG
                INT 21H

                MOV AX,0000H
                INT 21H

        RET
    MAIN ENDP

    CHAR_TYPES PROC NEAR
        ; Get user input value
        MOV AL,USER_IN

        ; is alpha-numeric?
            CMP AL,48
            JAE ALNUM_NUM
        CMP_ALNUM_MAYUS:
            CMP AL,65
            JAE ALNUM_ALM
        CMP_ALNUM_minus:
            CMP AL,97
            JAE ALNUM_ALmi
        JB CMP_ALPHA_MAYUS

        ALNUM_NUM:
            CMP AL,57
            JBE IS_ALNUM
            JMP CMP_ALNUM_MAYUS
        
        ALNUM_ALM:
            CMP AL,90
            JBE IS_ALNUM
            JMP CMP_ALNUM_minus

        ALNUM_ALmi:
            CMP AL,122
            JBE IS_ALNUM
            JMP CMP_ALPHA_MAYUS

        IS_ALNUM:
            MOV AH,09H
            LEA DX,ALNUM_MSG
            INT 21H

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            XOR AX,AX
            MOV AL,USER_IN

        ; is alpha?
        CMP_ALPHA_MAYUS:
            CMP AL,65
            JAE ALPHA_ALM
        CMP_ALPHA_minus:
            CMP AL,97
            JAE ALPHA_ALmi
        JB CMP_ASCII_0

        ALPHA_ALM:
            CMP AL,90
            JBE IS_ALPHA
            JMP CMP_ALPHA_minus

        ALPHA_ALmi:
            CMP AL,122
            JBE IS_ALPHA
            JMP CMP_ASCII_0

        IS_ALPHA:
            MOV AH,09H
            LEA DX,ALPHA_MSG
            INT 21H

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            XOR AX,AX
            MOV AL,USER_IN

        ; is ascii?
        CMP_ASCII_0:
            CMP AL,0
            JAE ASCII_127
        JB CMP_CNTRL_0

        ASCII_127:
            CMP AL,127
            JBE IS_ASCII
            JMP CMP_CNTRL_0

        IS_ASCII:
            MOV AH,09H
            LEA DX,ASCII_MSG
            INT 21H

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            XOR AX,AX
            MOV AL,USER_IN

        ; is control?
        CMP_CNTRL_0:
            CMP AL,0
            JAE CNTRL_31
        CMP_CNTRL_127:
            CMP AL,127
            JE IS_CNTRL
        JMP CMP_DIGIT_0
        
        CNTRL_31:
            CMP AL,31
            JBE IS_CNTRL
            JMP CMP_CNTRL_127

        IS_CNTRL:
            MOV AH,09H
            LEA DX,CNTRL_MSG
            INT 21H

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            XOR AX,AX
            MOV AL,USER_IN
        
        ; is digit?
        CMP_DIGIT_0:
            CMP AL,48
            JAE CMP_DIGIT_57
        JMP NEXT

        CMP_DIGIT_57:
            CMP AL,57
            JBE IS_DIGIT
            JMP NEXT

        IS_DIGIT:
            MOV AH,09H
            LEA DX,DIGIT_MSG
            INT 21H

            MOV AH,09H
            LEA DX,NEW_LINE
            INT 21H

            XOR AX,AX
            MOV AL,USER_IN

        NEXT:

        MOV AH,09H
        LEA DX,NEW_LINE
        INT 21H

        RET
    CHAR_TYPES ENDP

    END
CODE ENDS