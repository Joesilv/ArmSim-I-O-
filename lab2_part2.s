	.equ 	Stdout, 1			@ Set input mode to be Output View
	.equ 	SWI_PrInt,0x6b		@ Writes an integer
	.equ 	SWI_Timer, 0x06d	@ System Time from exection
	.equ	SWI_PrStr, 0x69		@ Print a string
	.equ	SWI_Open, 0x66		@ Open a file
	.equ	SWI_Exit, 0x11		@ stop executing
	.equ	SWI_Close, 0x68		@ closes file handle
	
	@ ============================  System Time Saved  ==============================
	swi		SWI_Timer			@R0 has begining execution time
			MOV R6,R0
	@ ============================  Open File for Output  ===========================
	
	LDR 	R0,=OutFileName		@ set Name for output file
	MOV 	R1,#1				@ Mode is Output	
	swi 	SWI_Open			@ open file for output
	bcs		OutFileError		@ if error, branch
	LDR		R1,=OutFileHandle	@ load output file handle
	STR		R0,[R1]				@ save the file handle
	
	@ ============================  Write To Output File - Header  ==========================
	
	LDR 	R0,=OutFileHandle	
	LDR		R0,[R0]				@r0 = file handle
	LDR		R1,=HeaderMsg		@r1 = address of String
	swi		SWI_PrStr			@write string to file
	
	LDR 	R0,=OutFileHandle	
	LDR		R0,[R0]				
	LDR		R1,=HeaderLines		
	swi		SWI_PrStr
	
	BL		Tabover
	
	@ =========================  Read File  ===================================================
	
	LDR		R0,=InFileName		@ Set name for input file
	MOV		R1,#0				@ mode is input
	swi		SWI_Open			@ Open file for inout
	bcs 	InFileError			@ if error
	LDR		R1,=InFileHandle
	STR		R0,[R1]
	
RLoop:
	LDR 	R0,=InFileHandle
	LDR 	R0,[r0]
	swi		0x6c				@RdInt
	bcs		EofReached			@if error
	
	@----- The integer is now in r0---
	
	@ ==========================  Factorial Loop ===========================================
	
	LDR		R3,=1				@Hold value of multiplied, start at 1
	MOV		R4,r0				@r4 holds input value
	
	LDR 	R0,=OutFileHandle	
	LDR		R0,[R0]				
	MOV 	R1,R4				
	swi  	SWI_PrInt

loop:
	MUL 	R5,R3,R4			@ Multiply R3 and R4 save to R5
	MOV 	R3,R5				@ Move the result to make room for next loop.
	SUB		R4,R4,#1			@ Decriment loop by 1
	CMP		R4,#1				@ Break when loop is 1
	BNE		loop				@ Branch to Loop Above
	
	@ ===========================  Write to Output File - Factorial  ========================
	
	BL		Tabover				@ Branch to function that adds tabs
	
	LDR 	R0,=OutFileHandle	
	LDR		R0,[R0]				@r0 = file handle
	MOV 	R1,R3				@ Move total to R1 for output
	swi  	SWI_PrInt			@ Print
	
	BL		Tabover				
	@ ==========================  Write to Output File  -  System Time =====================
	swi		SWI_Timer			@R0 has the execution time
	MOV		R3,R0				@Execution time moved to R3
	LDR 	R0,=OutFileHandle	
	LDR		R0,[R0]				@r0 = file handle
	SUB		R3,R3,R6			@Subtract beggining and ending time, save
	MOV		R1,R3
	swi		SWI_PrInt			@Print Integer
	
	bal 	RLoop				@keep reading until end of file
	
EofReached:
	MOV R0, #Stdout
	LDR R1, =EndOfFileMsg
	swi SWI_PrStr
	
	@ ================================  Close a file   ================================
	LDR		r0,=InFileHandle
	LDR		r0,[r0]
	swi		SWI_Close
	
	LDR		r0,=OutFileHandle
	LDR		r0,[r0]
	swi		SWI_Close
	
	
	@ ================================  Branches  =====================================
Exit:
	swi		SWI_Exit			@Stop Executing	
	
Tabover:
	LDR 	R0,=OutFileHandle	
	LDR		R0,[R0]				@r0 = file handle
	LDR		R1,=InsertTabs		@r1 = address of String
	swi		SWI_PrStr			@write string to file
	MOV		PC,R14				@go back to reading code above
	
OutFileError:
	MOV 	R0, #Stdout
	LDR 	R1, =OutFileErrorMsg
	swi		SWI_PrStr
	bal		Exit				@Give up, go to end
	
NL:				.asciz			"\n"			
OutFileName:	.asciz 			"Outfile1.txt"
OutFileErrorMsg:	.asciz		"Unable to open output file \n"
	.align
InFileName:		.asciz			"Infile1.txt"
InFileError:	.asciz			"Unable to open input file\n"
EndOfFileMsg:	.asciz			"Reached end of input file"
	.align
InFileHandle:	.skip			4
HeaderMsg:			.asciz			"\n\t\tNumber\t\tFactorial\tTime Elapsed \r\n"
HeaderLines:		.asciz			"\t\t------\t\t---------\t------------\r\n"
InsertTabs:			.asciz			"\t\t"
OutFileHandle:	.word			0
	
	
	