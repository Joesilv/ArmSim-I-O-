	.equ 	Stdout, 1			@ Set input mode to be Output View
	.equ 	SWI_PrInt,0x6b		@ Writes an integer
	.equ 	SWI_Timer, 0x06d	@ System Time from exection
	.equ	SWI_PrStr, 0x69		@ Print a string
	.equ	SWI_Open, 0x66		@ Open a file
	.equ	SWI_Exit, 0x11		@ stop executing
	
	swi		SWI_Timer			@R0 has begining execution time
			MOV R6,R0
	LDR		R3,=1				@Hold value of multiplied, start at 1
	MOV		R4,#5

loop:
	MUL 	R5,R3,R4			@ Multiply R3 and R4 save to R5
	MOV 	R3,R5				@ Move the result to make room for next loop.
	SUB		R4,R4,#1			@ Decriment loop by 1
	CMP		R4,#1				@ Break when loop is 1
	BNE		loop				@ Branch to Loop Above
	
	@ ============================  Start Writing to Output  ===========================
	
	LDR 	R0,=OutFileName		@ set Name for output file
	MOV 	R1,#1				@ Mode is Output	
	swi 	SWI_Open			@ open file for output
	bcs		OutFileError		@ if error, branch
	LDR		R1,=OutFileHandle	@ load output file handle
	STR		R0,[R1]				@ save the file handle
	
	MOV 	R0,#Stdout			@ Set mode to output
	MOV 	R1,R3				@ Move total to R1 for output
	swi  	SWI_PrInt			@ Print
	
	MOV		R0,#Stdout				
	LDR		R1, =NL				@ Print Line
	swi		SWI_PrStr
	
	swi		SWI_Timer			@R0 has the execution time
	MOV		R3,R0				@Execution time moved to R3
	MOV		R0,#Stdout			@Mode set to output
	SUB		R3,R3,R6			@Subtract beggining and ending time, save
	MOV		R1,R3
	swi		SWI_PrInt			@Print Integer
	
	@ ================================  Branches  =====================================
	
Exit:
	swi		SWI_Exit			@Stop Executing
	
OutFileError:
	MOV 	R0, #Stdout
	LDR 	R1, =OutFileErrorMsg
	swi		SWI_PrStr
	bal		Exit				@Give up, go to end
	
NL:				.asciz			"\n"			@new line
OutFileName:	.asciz 			"Outfile1.txt"
OutFileErrorMsg:	.asciz			"Unable to open output file \n"
	.align
OutFileHandle:	.word			0
	
	
	