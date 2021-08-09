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
MAX_INPUT_LENGTH = 15

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
inputArray			SDWORD	INTEGER_COUNT DUP(?)

; Output Identifiers
outputNumbers		BYTE	"You entered these numbers:", 13, 10, 0
outputSum			BYTE	"The sum of the numbers is: ", 0
outputAverage		BYTE	"The rounded average of all the numbers is: ", 0
outputString		BYTE	MAX_INPUT_LENGTH DUP(?)

; Goodbye Identifiers
goodbye				BYTE	"Thank you for using my program. Hasta Luego!", 13, 10, 0

.code
main PROC
	
	; Print Introduction
	mDisplayString	offset programTitle
	mDisplayString	offset programByline

	; Print Instructions
	mDisplayString	offset instruction1

	; Set up our looping registers
	mov				ECX, INTEGER_COUNT
	mov				EDI, offset inputArray

_getUserInput:
	
	; Solicit user input of signed integers
	push			EDI
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

	; Move EDI pointer to next array index
	add				EDI, type SDWORD				

	loop			_getUserInput

	; Display output (numbers, sum, and rounded average)
	push			offset outputString
	push			offset inputArray
	push			offset outputAverage
	push			offset outputSum
	push			offset outputNumbers
	call			printOutput

	; Say goodbye
	call			CrLf
	call			CrLf
	mDisplayString	offset goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

ReadVal PROC uses EAX EBX ECX EDX ESI EDI
	push			EBP
	mov				EBP, ESP

	; Invoke the mGetString macro to get user input in the form of a string of digits
	mGetString		[EBP + 32], [EBP + 36], MAX_INPUT_LENGTH, [EBP + 40]		; Parameters: inputPrompt, inputString, inputLengthLimit, InputLength

	; Set up looping registers
	mov				ESI, [EBP + 36]
	mov				ECX, [EBP + 40]

	; If no input or input too long, then raise error.
	cmp				ECX, 0
	jle				_inputLengthError
	cmp				ECX, 12
	jge				_inputLengthError

	; Reset EAX and load first ASCII character
	mov				EAX, 0
	cld
	lodsb

	; Check first character for sign
	push			[EBP + 48]								; inputSign offset
	push			[EBP + 44]								; inputErrorFlag offset
	push			EAX
	call			validateFirstCharacter
	
	; Decrement ECX and verify it is greater than zero before checking next characters
	dec				ECX
	cmp				ECX, 0
	jle				_saveToArray

_nextCharacter:

	; Reset EAX and load next ASCII character
	mov				EAX, 0
	cld
	lodsb													; load string byte into AL

	; Validate ASCII character
	push			[EBP + 44]								; inputError offset
	push			EAX
	call			validateCharacter
	
	; If character was invalid, break loop
	mov				EAX, 0
	mov				EDX, [EBP + 44]
	cmp				EAX, [EDX]
	jne				_endRead

	loop			_nextCharacter

_saveToArray:

	; Set up registers
	mov				ESI, [EBP + 36]					; Address of user input string
	mov				EDI, [EBP + 52]					; Address of array index where result will go
	mov				ECX, [EBP + 40]					; Length of string
	mov				EBX, 0							; Starting value
	mov				EDX, 1							; 10s place

	; Set ESI to last character
	mov				EAX, ECX
	dec				EAX
	add				ESI, EAX

_addInteger:
	; Reset EAX and load next ASCII character
	mov				EAX, 0
	std
	lodsb

	; If character is a sign, check next character
	cmp				EAX, 2Bh		; + sign
	je				_multiplyBySignFlag
	cmp				EAX, 2Dh		; - sign
	je				_multiplyBySignFlag

	; Convert ASCII to hex integer value
	sub				EAX, 30h

	; Multiply by 10 ^ n
	push			EDX
	imul			EDX								; Result is stored in EDX:EAX
	add				EBX, EAX

	; Jump to error if overflow
	jo				_overflowError

	; Set up next cycle
	pop				EDX
	mov				EAX, EDX
	mov				EDX, 10
	imul			EDX
	mov				EDX, EAX

	loop			_addInteger

_multiplyBySignFlag:

	; Multiply by sign flag
	mov				EAX, EBX
	mov				EBX, [EBP + 48]					; sign (1 or -1)
	mov				EBX, [EBX]
	imul			EBX								; Result is stored in EDX:EAX

	; Reset sign flag
	mov				EBX, [EBP + 48]	
	mov				sdword ptr [EBX], 1

	; Save integer value to array
	mov				[EDI], EAX

	jmp				_endRead

_overflowError:

	; Fix stack and then use _inputLengthError to set flag
	pop				EDX
	jmp				_inputLengthError

_inputLengthError:

	; Set Error Flag
	mov				EAX, [EBP + 44]
	mov				DWORD ptr [EAX], 1
	jmp				_endRead

_endRead:

	pop				EBP
	ret				24
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

WriteVal PROC uses EAX EBX ECX EDX EDI
	push			EBP
	mov				EBP, ESP

	; Set up registers
	mov				EDX, [EBP + 28]							; Integer value to convert to string
	mov				EDI, [EBP + 32]							; Output Array
	mov				ECX, 10									; Maximum number of loops required
	mov				EBX, 1000000000							; Greatest possible divisor 10 ^ 9

	cmp				EAX, 0
	jl				_negativeNumber
	jmp				_getChar

_negativeNumber:

	neg				EDX
	mov				EAX, '-'
	STOSB			

_getChar:
	
	; Get leading digit
	mov				EAX, EDX
	cdq
	div				EBX										; Quotient = EAX. Remainder = EDX.
	
	; Save remainder
	push			EDX

	; If leading digit is zero, ensure it is not the first recorded digit
	cmp				EAX, 0
	jne				_saveChar
	push			EAX
	push			EBX
	mov				EAX, [EBP + 32]

_checkNextChar:

	; See if character written to output is non-zero
	mov				BL, BYTE PTR [EAX]
	cmp				BL, 31h
	jge				_nonLeadingZero

	; If not, check next character
	inc				EAX
	cmp				EDI, EAX
	jle				_leadingZero
	jmp				_checkNextChar

_leadingZero:

	; Restore registers
	pop				EBX
	pop				EAX

	jmp				_saveCharEnd

_nonLeadingZero:

	; Restore registers
	pop				EBX
	pop				EAX

_saveChar:

	; Save digit to output array
	add				EAX, 30h
	STOSB

_saveCharEnd:

	; Divide EBX (integer divisor) by 10
	mov				EAX, EBX
	cdq
	mov				EBX, 10
	div				EBX
	mov				EBX, EAX

	; Restore remainder 
	pop				EDX

	loop _getChar

	; Terminate string
	mov			EAX, 0
	STOSB

	; Display output string
	mDisplayString	[EBP + 32]

	; Clear output string
	mov				ECX, MAX_INPUT_LENGTH
	mov				EDI, [EBP + 32]
	mov				EAX, 0
	rep				STOSB

	pop				EBP
	ret				8
WriteVal ENDP

printOutput PROC uses EAX EBX ECX EDX ESI
	push			EBP
	mov				EBP, ESP

	; Set up registers
	mov				ECX, INTEGER_COUNT
	mov				ESI, [EBP + 40]

	; Print Title for entered numbers
	call			CrLf
	mDisplayString	[EBP + 28]

_printNumber:

	; Move next index value into EAX
	LODSD

	; Write number value as a string
	push			[EBP + 44]							; Output string offset
	push			EAX									; Integer Value to convert to string
	call			WriteVal

	; Unless we're on the last number, print a comma and a space between numbers
	cmp				ECX, 1
	je				_calculateSum

	mov				AL, ','
	call			WriteChar
	mov				AL, ' '
	call			WriteChar
	loop			_printNumber

_calculateSum:

	; Set up registers
	mov				ECX, INTEGER_COUNT
	mov				ESI, [EBP + 40]
	mov				EBX, 0								; Store Sum
_sumNext:

	; Load next array value into EAX
	LODSD
	add				EBX, EAX
	loop			_sumNext

	; Display Sum Title
	call			CrLf
	call			CrLf
	mDisplayString	[EBP + 32]

	; Display Sum
	mov				EAX, EBX
	push			[EBP + 44]							; Output string offset
	push			EAX									; Integer Value to convert to string
	call			WriteVal

_calculateAverage:

	; Divide Sum by number of intergers entered by the user
	mov				EBX, INTEGER_COUNT
	cdq
	idiv			EBX									; Quotient = EAX. Remainder = EDX.

	; Display Average Title
	call			CrLf
	call			CrLf
	mDisplayString	[EBP + 36]

	; Display Average
	push			[EBP + 44]							; Output string offset
	push			EAX									; Integer Value to convert to string
	call			WriteVal

	pop				EBP
	ret				16
printOutput ENDP

END main
