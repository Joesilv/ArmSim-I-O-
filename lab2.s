	.equ 	Stdout, 1			@ Set input mode to be Output View
	.equ 	SWI_PrInt,0x6b		@ Writes an integer
	.equ 	SWI_Timer, 0x06d	@ System Time from exection
	
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
	
	MOV 	R0,#Stdout			@ Set mode to output
	MOV 	R1,R3				@ Move total to R1 for output
	swi  	SWI_PrInt			@ Print
	
	swi		SWI_Timer			@R0 has the execution time
	MOV		R3,R0				@Execution time moved to R3
	MOV		R0,#Stdout			@Mode set to output
	SUB		R3,R3,R6			@Subtract beggining and ending time, save
	MOV		R1,R3
	swi		SWI_PrInt			@Print Integer
	
	
	
	
	