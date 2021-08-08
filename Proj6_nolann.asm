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
MAX_INPUT_LENGTH = 12 ; 11 characters plus terminating zero

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
inputErrorMsg		BYTE	"Error -- Please enter a valid signed integer.", 13, 10, 0

; Input Identifiers
userInput			BYTE	MAX_INPUT_LENGTH DUP(?)
inputLength			DWORD	0
inputErrorFlag		DWORD	0
inputSign			SDWORD	1

; Output String Identifiers
outputNumbers		BYTE	"You entered these numbers:", 13, 10, 0
outputSum			BYTE	"The sum of the numbers is: ", 0
outputAverage		BYTE	"The rounded average of all the numbers is: ", 0

; Goodbye Identifiers
goodbye				BYTE	"Thank you for using my program. Hasta Luego!", 13, 10, 0

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
	push			offset inputSign
	push			offset inputErrorFlag
	push			offset inputLength
	push			offset userInput
	push			offset inputRequest
	call			ReadVal

	; If invalid input, print error and retry
	cmp				inputErrorFlag, 0
	jne				_inputErrorMessage
	jmp				_inputErrorMessageEnd

_inputErrorMessage:

	mDisplayString	offset inputErrorMsg
	mov				inputErrorFlag, 0
	jmp				_getUserInput

_inputErrorMessageEnd:

	loop			_getUserInput

	; Convert inputs to SDWORD Array

	; Display output (numbers, sum, and rounded average)

	; Say goodbye
	mDisplayString offset goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

ReadVal PROC uses EAX ECX EDX ESI
	push			EBP
	mov				EBP, ESP

	; Invoke the mGetString macro to get user input in the form of a string of digits
	mGetString		[EBP + 24], [EBP + 28], MAX_INPUT_LENGTH, [EBP + 32]		; Parameters: inputPrompt, inputString, inputLengthLimit, InputLength

	; Set up looping registers
	mov				ESI, [EBP + 28]
	mov				ECX, [EBP + 32]

	; If no input or input too long, then raise error.
	cmp				ECX, 0
	jle				_inputLengthError
	cmp				ECX, 12
	jge				_inputLengthError

	; Check first character for sign
	mov				EAX, 0
	cld
	lodsb
	push			[EBP + 40]								; inputSign offset
	push			[EBP + 36]								; inputErrorFlag offset
	push			EAX
	call			validateFirstCharacter
	
	; Decrement ECX and verify it is greater than zero before checking next characters
	dec				ECX
	cmp				ECX, 0
	jle				_endRead

_nextCharacter:

	; Reset EAX and load next ASCII character
	mov				EAX, 0
	cld
	lodsb													; load string byte into AL

	; Validate ASCII character
	push			[EBP + 36]								; inputError offset
	push			EAX
	call			validateCharacter
	
	; If character was invalid, break loop
	mov				EAX, 0
	mov				EDX, [EBP + 36]
	cmp				EAX, [EDX]
	jne				_endRead

	loop			_nextCharacter
	
	; Store the value into a memory variable
	
	jmp				_endRead

_inputLengthError:

	; Set Error Flag
	mov				EAX, [EBP + 36]
	mov				DWORD ptr [EAX], 1

_endRead:

	pop				EBP
	ret				20
ReadVal ENDP

validateFirstCharacter PROC
	push			EBP
	mov				EBP, ESP

	; Move ASCII character to EAX
	mov				EAX, [EBP + 8]

	; Check if character is a plus or minus sign
	cmp				EAX, 2Bh		; + sign
	je				_errorFirstCharEnd
	cmp				EAX, 2Dh		; - sign
	je				_minusSign

	; Check if character is in the range of 30 [0] to 39 [9]
	cmp				EAX, 30h
	jb				_errorFirstChar
	cmp				EAX, 39h
	ja				_errorFirstChar
	jmp				_errorFirstCharEnd

_minusSign:

	; Store the negative sign
	mov				EAX, [EBP + 16]
	mov				EDX, -1
	mov				[EAX], EDX
	jmp				_errorFirstCharEnd

_errorFirstChar:
	
	mov				EAX, [EBP + 12]
	mov				DWORD ptr [EAX], 1		; Set error flag

_errorFirstCharEnd:

	pop				EBP
	ret				12
validateFirstCharacter ENDP

validateCharacter PROC
	push			EBP
	mov				EBP, ESP


	; Move ASCII character to EAX
	mov				EAX, [EBP + 8]

	; Check if character is in the range of 48 [0] to 57 [9]
	cmp				EAX, 30h
	jb				_error

	cmp				EAX, 39h
	ja				_error

	; If character is in range, character is valid
	jmp				_errorEnd

_error:

	mov				EAX, [EBP + 12]
	mov				DWORD ptr [EAX], 1		; Set error flag

_errorEnd:

	pop				EBP
	ret				8
validateCharacter ENDP

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

printOutput PROC
	push			EBP
	mov				EBP, ESP

	mDisplayString	[EBP + 8]

	pop				EBP
	ret				8
printOutput ENDP

END main
