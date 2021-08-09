TITLE Project 6 - String Primitives and Macros     (Proj6_nolann.asm)

; Author: Nic Nolan
; Last Modified: 08/09/2021
; OSU email address: nolann@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: #6                Due Date: 08/13/2021
; Description: This progam does the following:
;	1) Requests 10 user-inputted signed-integers (32 bit signed max). Invalid integers require
;		the user to input a new signed integer until the input is valid.
;	2) Prints the 10 valid numbers the user entered.
;	3) Calculates and prints the sum of the 10 numbers.
;	4) Calculates and prints the rounded average of the 10 numbers.
;	5) Says goodbye to the user.

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString 
; 
; Description: Prints an input prompt and gets input from the user.
; 
; Preconditions: All arguments should be initialized.
; 
; Receives: 
;	inputPrompt			: Address offset of a string requesting user input.
;	inputString			: Address offset where user input should be stored.
;	inputLengthLimit	: The number of bytes that should be captured during user input.
;	inputStringLength	: Address offset where the length of the user input should be stored.
; 
; Returns:
;	inputString			: The user input is stored at the corresponding address offset.
;	inputStringLength	: The length of the user input is stored at the corresponding address offset.
; ---------------------------------------------------------------------------------
mGetString MACRO inputPrompt, inputString, inputLengthLimit, inputStringLength, outputStringOffset, inputTotalString, inputTotal, inputNumber

	; Save register values
	push			EAX
	push			ECX
	push			EDX

	; Print current total
	call			CrLf
	mDisplayString	inputTotalString
	push			outputStringOffset
	push			inputTotal
	call			WriteVal
	call			CrLf

	; Print input prompt
	mDisplayString	inputPrompt
	push			outputStringOffset
	push			inputNumber
	call			WriteVal
	mov				AL, ':'
	call			WriteChar
	mov				AL, ' '
	call			WriteChar

	; Get and save user input
	mov				EDX, inputString
	mov				ECX, inputLengthLimit
	call			ReadString					; Returns: EAX = Number of characters entered.
	mov				inputStringLength, EAX

	; Restore register values
	pop				EDX
	pop				ECX
	pop				EAX

ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString 
; 
; Description: Prints the argument string into the console window.
; 
; Preconditions: The argument string should be initialized.
; 
; Receives: 
;	outputStringOffset	: Address offset of string to be printed.
; 
; Returns: The string is printed into the console window.
; ---------------------------------------------------------------------------------
mDisplayString MACRO outputStringOffset

	; Save register values
	push			EDX

	; Print string
	mov				EDX, outputStringOffset
	call			WriteString

	; Restore register values
	pop				EDX

ENDM

; Constants
INTEGER_COUNT = 10
MAX_INPUT_LENGTH = 15

.data

; Program Opening Identifiers
programTitle		BYTE	"Project 6 - String Primitives and Macros", 13, 10, 0
programByline		BYTE	"By Nic Nolan", 13, 10, 13, 10, 0

; Instruction Identifiers
instructions		BYTE	"Hello there. This program takes 10 signed integers from the user.", 13, 10
					BYTE	"It then displays the integers, their sum, and the rounded average of the numbers.", 13, 10
					BYTE	"Each integer must be in the range of -2147483647 to 2147483647 (1 signed 32-bit integer).",13, 10, 13, 10, 0

; Prompt Identifiers
inputTotal			BYTE	"Current Total is: ", 0
inputRequest		BYTE	"Please enter signed integer #", 0

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

; ----------------------------------------------------
; PRINT INTRODUCTION
;
;	Prints the project name and the author's name into
;	the console window.
; ---------------------------------------------------- 
	mDisplayString	offset programTitle
	mDisplayString	offset programByline

; ---------------------------------------------------- 
; PRINT INSTRUCTIONS
;
;	Prints the project instructions into the console
;	window.
; ---------------------------------------------------- 
	mDisplayString	offset instructions

; ----------------------------------------------------  
; GET USER INPUT
;
;	This section prompts the user to input valid integers.
;	If the user input is valid, it will continue requesting
;	until INTEGER_COUNT of integers have been recorded.
;
;	If the user input is invalid, the user will be prompted
;	to re-enter another integer until the input is valid.
; ----------------------------------------------------

	; Set up looping registers
	mov				ECX, INTEGER_COUNT
	mov				EDI, offset inputArray

_getUserInput:
	
	; Solicit user input of signed integers
	push			offset inputTotal
	push			offset inputArray
	push			ECX
	push			offset outputString
	push			offset inputErrorMsg
	push			EDI
	push			offset inputSign
	push			offset inputErrorFlag
	push			offset inputLength
	push			offset userInput
	push			offset inputRequest
	call			ReadVal

	; Move EDI pointer to next array index
	add				EDI, type SDWORD				

	loop			_getUserInput

; ---------------------------------------------------- 
; DISPLAY OUTPUT
;
;	This section does the following:
;
;	1. Prints each of the numbers entered by the user.
;
;	2. Calculate and prints the sum of the numbers
;		entered by the user.
;
;	3. Calculate and prints the rounded average of the
;		numbers entered by the user.
; ----------------------------------------------------
	push			offset outputString
	push			offset inputArray
	push			offset outputAverage
	push			offset outputSum
	push			offset outputNumbers
	call			printOutput

; ----------------------------------------------------
; SAY GOODBYE
;
;	Prints the goodbye message into the console window.
; ----------------------------------------------------
	call			CrLf
	call			CrLf
	mDisplayString	offset goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; --------------------------------------------------------------------------------- 
; Name: ReadVal 
;  
; Description: This procedure prompts the user to input integers. Valid integers are
;				converted from strings to their SDWORD equivalents and saved to an
;				address location. 
; 
; Preconditions: Argument addresses should be valid. Data at addresses should be initialized.
; 
; Postconditions: Registers are restored after procedure call.
; 
; Receives: [EBP + 32] -> Address offset of input request prompt.
;			[EBP + 36] -> Address offset of where user string input should be saved.
;			[EBP + 40] -> Address offset of where the user input string length should be saved.
;			[EBP + 44] -> Address offset of where the input error flag should be saved.
;			[EBP + 48] -> Address offset of where the sign of user input should be saved.
;			[EBP + 52] -> Address offset of where the converted SDWORD value should be saved.
;			[EBP + 56] -> Address offset of input error message.
;			[EBP + 60] -> Address offset of output string for WriteVal
;			[EBP + 64] -> ECX value
;			[EBP + 68] -> Address offset of input array
;			[EBP + 72] -> Address offset of input total message
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 36] -> Address offset of where user string input is saved.
;			[EBP + 40] -> Address offset of where the user input string length is saved.
;			[EBP + 44] -> Address offset of where the input error flag is saved.
;			[EBP + 48] -> Address offset of where the sign of user input is saved.
;			[EBP + 52] -> Address offset of where the converted SDWORD value is saved.
; ---------------------------------------------------------------------------------
ReadVal PROC uses EAX EBX ECX EDX ESI EDI
	push			EBP
	mov				EBP, ESP

_getInput:

	; Calculate current input number
	mov				EAX, INTEGER_COUNT
	sub				EAX, [EBP + 64]
	inc				EAX
	push			EAX

	; Calculate current sum
	; Set up registers
	mov				ECX, EAX
	mov				ESI, [EBP + 68]
	mov				EBX, 0								; Store Sum

_sumNextInteger:
	; Load next array value into EAX
	mov				EAX, 0
	cld
	LODSD
	add				EBX, EAX
	loop			_sumNextInteger
	pop				EAX

	; Invoke the mGetString macro to get user input in the form of a string of digits
	mGetString		[EBP + 32], [EBP + 36], MAX_INPUT_LENGTH, [EBP + 40], [EBP + 60], [EBP + 72], EBX, EAX

	; Validate the string
	push			[EBP + 48]							; Address offset of sign
	push			[EBP + 44]							; Address offset of error flag
	push			[EBP + 40]							; Address offset of input string length
	push			[EBP + 36]							; Address offset of input string
	call			validateString

	; If invalid input, print error and retry
	mov				EAX, [EBP + 44]
	mov				EAX, [EAX]
	cmp				EAX, 0
	jne				_errorMessage

	; Save the input as a SDWORD
	push			[EBP + 52]							; Address offset of where SDWORD should be saved
	push			[EBP + 48]							; Address offset of sign
	push			[EBP + 44]							; Address offset of error flag
	push			[EBP + 40]							; Address offset of input string length
	push			[EBP + 36]							; Address offset of input string
	call			stringToSDWORD

	; Check there is no overflow error
	mov				EAX, [EBP + 44]
	mov				EAX, [EAX]
	cmp				EAX, 0
	je				_errorMessageEnd

_errorMessage:

	; Display error message
	mDisplayString	[EBP + 56]

	; Reset error flag
	mov				EAX, [EBP + 44]
	mov				DWORD ptr [EAX], 0

	jmp				_getInput

_errorMessageEnd:

	pop				EBP
	ret				44
ReadVal ENDP

; --------------------------------------------------------------------------------- 
; Name: validateString
;  
; Description: This procedure checks each character in the argument string to ensure
;				it is valid. If it is not, the error flag is set.
; 
; Preconditions: Argument addresses should be valid. Data at addresses should be initialized.
; 
; Postconditions: Registers are restored after procedure call.
; 
; Receives: 
;			[EBP + 24] -> Address offset of where user string input is saved.
;			[EBP + 28] -> Address offset of where the user input string length is saved.
;			[EBP + 32] -> Address offset of where the input error flag should be saved.
;			[EBP + 36] -> Address offset of where the sign of user input should be saved.
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 32] -> Address offset of where the input error flag is saved.
;			[EBP + 36] -> Address offset of where the sign of user input is saved.
; ---------------------------------------------------------------------------------
validateString PROC uses EAX ECX EDX ESI
	push			EBP
	mov				EBP, ESP

	; Set up looping registers
	mov				ESI, [EBP + 24]						; Input string address
	mov				ECX, [EBP + 28]						; Input string length

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
	push			[EBP + 36]							; inputSign offset
	push			[EBP + 32]							; inputErrorFlag offset
	push			EAX
	call			validateFirstCharacter
	
	; Decrement ECX and verify it is greater than zero before checking next characters
	dec				ECX
	cmp				ECX, 0
	jle				_validateEnd

_nextCharacter:

	; Reset EAX and load next ASCII character
	mov				EAX, 0
	cld
	lodsb												; load string byte into AL

	; Validate ASCII character
	push			[EBP + 32]							; inputError offset
	push			EAX
	call			validateCharacter
	
	; If character was invalid, break loop
	mov				EAX, 0
	mov				EDX, [EBP + 32]
	cmp				EAX, [EDX]
	jne				_validateEnd

	loop			_nextCharacter
	
	jmp				_validateEnd

_inputLengthError:

	; Set Error Flag
	mov				EAX, [EBP + 32]
	mov				DWORD ptr [EAX], 1

_validateEnd:

	pop				EBP
	ret				16
validateString ENDP

; --------------------------------------------------------------------------------- 
; Name: validateFirstCharacter 
;  
; Description: This procedure validates the first character of a user string input.
;				It allows characters that are +, -, or numerical inputs (in ASCII).
;				If the character is not valid, the error flag is set.
;				If a negative sign is found, the sign flag is set to -1.
; 
; Preconditions: Argument addresses should be valid. Data at addresses should be initialized.
; 
; Postconditions: Registers are restored after procedure call.
; 
; Receives: [EBP + 16] -> ASCII character byte (hexadecimal)
;			[EBP + 20] -> Address offset of where the input error flag should be saved.
;			[EBP + 24] -> Address offset of where the sign of the user input should be saved.
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 20] -> Address offset of where the input error flag is saved.
;			[EBP + 24] -> Address offset of where the sign of the user input is saved.
; ---------------------------------------------------------------------------------
validateFirstCharacter PROC uses EAX EDX
	push			EBP
	mov				EBP, ESP

	; Move ASCII character to EAX
	mov				EAX, [EBP + 16]

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

	; Set the sign flag to -1
	mov				EAX, [EBP + 24]
	mov				EDX, -1
	mov				[EAX], EDX
	jmp				_errorFirstCharEnd

_errorFirstChar:
	
	; Set error flag
	mov				EAX, [EBP + 20]
	mov				DWORD ptr [EAX], 1

_errorFirstCharEnd:

	pop				EBP
	ret				12
validateFirstCharacter ENDP

; --------------------------------------------------------------------------------- 
; Name: validateCharacter 
;  
; Description: This procedure validates a character of a user string input.
;				It allows characters that are numerical inputs (in ASCII).
;				If the character is not valid, the error flag is set.
; 
; Preconditions: Argument addresses should be valid. Data at addresses should be initialized.
; 
; Postconditions: Registers are restored after procedure call.
; 
; Receives: [EBP + 12] -> ASCII character byte (hexadecimal)
;			[EBP + 16] -> Address offset of where the input error flag should be saved.
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 16] -> Address offset of where the input error flag is saved.
; ---------------------------------------------------------------------------------
validateCharacter PROC uses EAX
	push			EBP
	mov				EBP, ESP

	; Move ASCII character to EAX
	mov				EAX, [EBP + 12]

	; Check if character is in the range of 48 [0] to 57 [9]
	cmp				EAX, 30h
	jb				_error
	cmp				EAX, 39h
	ja				_error

	; If character is in range, character is valid
	jmp				_errorEnd

_error:

	; Set error flag
	mov				EAX, [EBP + 16]
	mov				DWORD ptr [EAX], 1		

_errorEnd:

	pop				EBP
	ret				8
validateCharacter ENDP

; --------------------------------------------------------------------------------- 
; Name: stringToSDWORD 
;  
; Description: This procedure converts a string to a signed double word (SDWORD) value.
;				If the value is too large, the error flag is set.
; 
; Preconditions: Argument addresses should be valid. Data at addresses should be initialized.
; 
; Postconditions: Registers are restored after procedure call.
; 
; Receives:
;			[EBP + 32] -> Address offset of where user string input should be saved.
;			[EBP + 36] -> Address offset of where the user input string length should be saved.
;			[EBP + 40] -> Address offset of where the input error flag should be saved.
;			[EBP + 44] -> Address offset of where the sign of user input should be saved.
;			[EBP + 48] -> Address offset of where the converted SDWORD value should be saved.
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 40] -> Address offset of where the input error flag is saved.
;			[EBP + 48] -> Address offset of where the converted SDWORD value is saved.
; ---------------------------------------------------------------------------------
stringToSDWORD PROC uses EAX EBX ECX EDX ESI EDI
	push			EBP
	mov				EBP, ESP

	; Set up registers
	mov				ESI, [EBP + 32]						; Address of user input string
	mov				EDI, [EBP + 48]						; Address of array index where result will go
	mov				ECX, [EBP + 36]						; Length of string
	mov				EBX, 0								; Starting value
	mov				EDX, 1								; 10s place

	; Set ESI to last character
	mov				EAX, ECX
	dec				EAX
	add				ESI, EAX

_addInteger:
	; Reset EAX and load next ASCII character
	mov				EAX, 0
	std
	lodsb

	; If character is a sign, we are at the end of the string.
	cmp				EAX, 2Bh		; + sign
	je				_multiplyBySignFlag
	cmp				EAX, 2Dh		; - sign
	je				_multiplyBySignFlag

	; Convert ASCII to hex integer value
	sub				EAX, 30h

	; Multiply integer value by 10 ^ n
	push			EDX
	imul			EDX									; Result is stored in EDX:EAX
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

	; Multiply final integer by its sign flag
	mov				EAX, EBX
	mov				EBX, [EBP + 44]						; sign (1 or -1)
	mov				EBX, [EBX]
	imul			EBX									; Result is stored in EDX:EAX

	; Reset sign flag
	mov				EBX, [EBP + 44]	
	mov				sdword ptr [EBX], 1

	; Save integer value to array
	mov				[EDI], EAX

	jmp				_stringToSDWORDEnd

_overflowError:

	; Fix stack
	pop				EDX

	; Set Error Flag
	mov				EAX, [EBP + 40]
	mov				DWORD ptr [EAX], 1

_stringToSDWORDEnd:

	pop				EBP
	ret				20
stringToSDWORD ENDP

; --------------------------------------------------------------------------------- 
; Name: WriteVal 
;  
; Description: This procedure converts signed double word (SDWORD) integer values to
;				strings and prints them to the console.
; 
; Preconditions: Argument addresses should be valid. Data at addresses should be initialized.
; 
; Postconditions: Registers are restored after procedure call.
; 
; Receives: [EBP + 28] -> SDWORD value to convert to string
;			[EBP + 32] -> Address offset of where output string should be saved.
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 32] -> Address offset of where output string is saved.
; ---------------------------------------------------------------------------------
WriteVal PROC uses EAX EBX ECX EDX EDI
	push			EBP
	mov				EBP, ESP

	; Set up registers
	mov				EDX, [EBP + 28]						; Integer value to convert to string
	mov				EDI, [EBP + 32]						; Output Array
	mov				ECX, 10								; Maximum number of loops required
	mov				EBX, 1000000000						; Greatest possible divisor 10 ^ 9

	; Check if SDWORD is a negative number
	cmp				EDX, 0
	jl				_negativeNumber
	jmp				_getChar

_negativeNumber:
	
	; Convert integer to twos complement
	neg				EDX

	; Save first output character as a minus symbol
	mov				EAX, '-'
	STOSB			

; ---------------------------------------------------- 
; GET AND SAVE LEADING DIGIT OF INTEGER INPUT
;
;	This section does the following:
;
;	1. Gets the leading digit of the integer input.
;
;	2. Converts the leading digit to ASCII.
;
;	3. Saves the ASCII character as a BYTE to the output string.
;
;	4. The remainder becomes the new input.
;
;	5. Repeat steps 1 - 4 until we reach the end of the integer.
; ----------------------------------------------------
_getChar:
	
	; Get leading digit
	mov				EAX, EDX
	cdq
	div				EBX									; Quotient = EAX. Remainder = EDX.
	
	; Save remainder
	push			EDX

	; If leading digit is not zero, or it is the last digit, we always save it.
	cmp				EAX, 0
	jne				_saveChar
	cmp				ECX, 1
	je				_saveChar

	; Otherwise, prepare to check if there are other recorded digits before we save the zero
	push			EAX
	push			EBX
	mov				EAX, [EBP + 32]

; ---------------------------------------------------- 
; CHECK FOR NON-ZERO DIGIT IN OUTPUT STRING
;
;	Because we are dividing the integer input by a large
;	number each time, inputs that are less than 10
;	digits in length would have leading zeros if we
;	input them normally. IE: 123 --> 0000000123.
;
;	This is undesirable, so we ensure that a digit has
;	been recorded to the output before we add any zeros.
; ----------------------------------------------------
_checkNextChar:

	; See if a character previously written to output is non-zero
	mov				BL, BYTE PTR [EAX]
	cmp				BL, 31h
	jge				_nonLeadingZero

	; If not, check next character
	inc				EAX
	cmp				EDI, EAX
	jle				_leadingZero
	jmp				_checkNextChar

; ---------------------------------------------------- 
; QUOTIENT IS A LEADING ZERO
;
;	When the quotient is a leading zero, we only need
;	to restore our registers and skip the saving step.
; ----------------------------------------------------
_leadingZero:

	; Restore registers
	pop				EBX
	pop				EAX

	jmp				_saveCharEnd

; ---------------------------------------------------- 
; QUOTIENT IS A NON-LEADING ZERO
;
;	When the quotient is a non-leading zero, we restore
;	our registers and then follow the normal save step.
; ----------------------------------------------------
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

	loop			_getChar

	; Terminate string
	mov				EAX, 0
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

; --------------------------------------------------------------------------------- 
; Name: printOutput 
;  
; Description: This procedure prints each of the numbers in the argument array. It
;				then calculates and prints the sum of the numbers, as well as the
;				rounded average of the numbers.
; 
; Preconditions: Argument addresses should be valid.
; 
; Postconditions: Registers are restored after procedure call. Data at addresses should be initialized.
; 
; Receives: [EBP + 28] -> Address offset of title for entered numbers ("You entered these numbers: ").
;			[EBP + 32] -> Address offset of title for sum of numbers ("The sum is: ").
;			[EBP + 36] -> Address offset of title for average of numbers ("The average is: ").
;			[EBP + 40] -> Address offset of the array of numbers to be displayed, summed, and averaged.
;			[EBP + 44] -> Address offset of where each output string should be saved.
;
; Returns: The following data may be changed after this procedure:
;			[EBP + 44] -> Address offset of where each output string should be saved.
; ---------------------------------------------------------------------------------
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
