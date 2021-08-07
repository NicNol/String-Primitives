TITLE Project 6 - String Primitives and Macros     (Proj6_nolann.asm)

; Author: Nic Nolan
; Last Modified: 08/04/2021
; OSU email address: nolann@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: #6                Due Date: 08/13/2021
; Description: 

INCLUDE Irvine32.inc

mGetString MACRO inputPrompt, inputString, inputLengthLimit, inputStringLength

	; Save register values
	push	EAX
	push	ECX
	push	EDX

	; Print input prompt
	mDisplayString inputPrompt

	; Get user input as string
	mov		EDX, inputString
	mov		ECX, inputLengthLimit
	call	ReadString						; Returns: EAX = Number of characters entered.
	mov		inputStringLength, EAX

	; Restore register values
	pop		EDX
	pop		ECX
	pop		EAX

ENDM

mDisplayString MACRO outputStringOffset

	; Save register values
	push	EDX

	; Print string
	mov		EDX, outputStringOffset
	call	WriteString

	; Restore register values
	pop		EDX

ENDM

; Constants
INTEGER_COUNT = 10
MAX_INPUT_LENGTH = 11

.data

; Program Opening Identifiers
programTitle		BYTE	"Project 6 - String Primitives and Macros", 13, 10, 0
programByline		BYTE	"By Nic Nolan", 13, 10, 13, 10, 0

; Instruction Identifiers
instruction1		BYTE	"Hello there. This program takes 10 signed integers from the user.", 13, 10
					BYTE	"It then displays the integers, their sum, and the rounded average of the numbers.", 13, 10
					BYTE	"Each integer must be in the range of -2147483648 to 2147483647 (1 signed 32-bit integer).",13, 10, 13, 10, 0

; Prompt Identifiers
inputRequest		BYTE	"Please enter a signed integer: ", 0

; Error Identifiers
inputError			BYTE	"Error -- Please enter a valid signed integer.", 13, 10, 0

; Input Identifiers
userInput			BYTE	MAX_INPUT_LENGTH DUP(?)
inputLength			DWORD	0
inputValidity		DWORD	0

.code
main PROC
	
	; Print Introduction
	push			offset programByline
	push			offset programTitle
	call			printIntroduction

	; Print Instructions
	push			offset instruction1
	call			printInstructions

	; Get the required number of user inputs
	mov				ECX, INTEGER_COUNT

_getUserInput:
	
	; Solicit user input of signed integers
	push			offset inputValidity
	push			offset inputLength
	push			offset userInput
	push			offset inputRequest
	call			ReadVal

	loop			_getUserInput

	Invoke ExitProcess,0	; exit to operating system
main ENDP

ReadVal PROC uses ECX EDX
	push			EBP
	mov				EBP, ESP

	; Invoke the mGetString macro to get user input in the form of a string of digits
	mGetString		[EBP + 16], [EBP + 20], MAX_INPUT_LENGTH, [EBP + 24]		; Parameters: inputPrompt, inputString, inputLengthLimit, InputLength

	; Convert the string of ascii digits to SDWORD, validating the user's input.
	
	lodsb			; load string byte into AL
	
	call			validateCharacter
	
	
	; Store the value into a memory variable


	pop				EBP
	ret		
ReadVal ENDP

validateFirstCharacter PROC
	push			EBP
	mov				EBP, ESP

	mov				EAX, [EBP + 8]
	cmp				EAX, 43		; is character + sign
	je				_plusSign
	cmp				EAX, 45		; is character - sign
	je				_minusSign

	pop				EBP
	ret		
validateFirstCharacter ENDP

validateCharacter PROC
	push			EBP
	mov				EBP, ESP




	pop				EBP
	ret		
validateValue ENDP

clearString PROC
	push			EBP
	mov				EBP, ESP

	pop				EBP
	ret		
clearString ENDP

WriteVal PROC
	push			EBP
	mov				EBP, ESP

	pop				EBP
	ret		
WriteVal ENDP

printIntroduction PROC uses EDX
	push			EBP
	mov				EBP, ESP

	; Program Title
	mDisplayString	[EBP + 12]

	; Program Author
	mDisplayString	[EBP + 16]

	pop				EBP
	ret				8
printIntroduction ENDP

printInstructions PROC uses EDX
	push			EBP
	mov				EBP, ESP

	mDisplayString	[EBP + 12]

	pop				EBP
	ret				8
printInstructions ENDP

END main
