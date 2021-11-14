# String Primitives

This is the final project for a course on computer architecture and assembly language. It was programmed using x86 Microsoft Macro Assembler (MASM). 

Please see `Proj6_nolann.asm` for the project code. Please see `Project Instructions.md` for the full assignment instructions.

This project allows the user to input 10 strings comprised only of digits (0 through 9) with the option to include a sign (+ or -). The user input is validated and then converted to integer type. All 10 numbers are summed together, converted to a string, and then printed to the user.

Example usage:
<pre><code>Project 6 - String Primitives and Macros
By Nic Nolan

Extra Credit #1: each line of user input is numbered, with a running total of the valid inputs.

Hello there. This program takes 10 signed integers from the user.
It then displays the integers, their sum, and the rounded average of the numbers.
Each integer must be in the range of -2147483647 to 2147483647 (1 signed 32-bit integer).


Current Total is: 0
Please enter signed integer #1: <b>156</b>

Current Total is: 156
Please enter signed integer #2: <b>51d6fd</b>
Error -- Please enter a valid signed integer.

Current Total is: 156
Please enter signed integer #2: <b>34</b>

Current Total is: 190
Please enter signed integer #3: <b>-186</b>

Current Total is: 4
Please enter signed integer #4: <b>115616148561615630</b>
Error -- Please enter a valid signed integer.

Current Total is: 4
Please enter signed integer #4: <b>-145</b>

Current Total is: -141
Please enter signed integer #5: <b>5</b>

Current Total is: -136
Please enter signed integer #6: <b>+23</b>

Current Total is: -113
Please enter signed integer #7: <b>51</b>

Current Total is: -62
Please enter signed integer #8: <b>0</b>

Current Total is: -62
Please enter signed integer #9: <b>56</b>

Current Total is: -6
Please enter signed integer #10: <b>11</b>

You entered these numbers:
156, 34, -186, -145, 5, 23, 51, 0, 56, 11

The sum of the numbers is: 5

The rounded average of all the numbers is: 0

Thank you for using my program. Hasta Luego!
</code></pre>


