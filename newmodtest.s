main:

	//bl TestPrint
	//stop

	bl TestMult	// Uncomment to test Naive implementation first
	stop

InitZeros:
	// input:
	// x0: address of (pointer to) the first symbol of input array
	// output:
	// x1: value specifying the number of values that will be set to 0
 
	ADDI X9, XZR, #0
	ORR X11, X0, XZR
	ADDI X10, XZR, #0
	
loop:	STUR X10,[X11, #0]
	ADDI X9, X9, #1
	ADDI X11, X11, #8
	SUBS XZR, X9, X1
	B.LT loop
 
	br lr



NaiveMult:
	SUBI SP, SP, #32
	STUR X19, [SP, #0]
	STUR X20, [SP, #8]
	STUR X21, [SP, #16]
	STUR LR, [SP, #24]
	
	ADDI X19, X0, #0
	ADDI X20, X1, #0 
	ADDI X21, X2, #0	
	
	LSL X4, X3, #1
	ADDI X4, X4, #1	
	ADDI X1, X4, #0
	BL InitZeros
	
	ADDI X5, XZR, #0     // i=0
	ADDI X28, XZR, #0    // total iteration counter for safety
	
	iloopNM:
		// Safety counter
		ADDI X28, X28, #1
		SUBI X29, X28, #20    // Limit to 20 total iterations
		B.GT force_exit
		
		SUBS XZR, X5, X3
		B.GT iloopendNM
		
		ADDI X6, XZR, #0     // j=0
		
		jloopNM:
			SUBS XZR, X6, X3
			B.GT jloopendNM
			
			// Debug: Print current i,j values
			ADDI X11, X5, #48    // Convert i to ASCII (0='0', 1='1', etc.)
			putchar X11          // Print i
			ADDI X11, XZR, #32   // Space
			putchar X11
			ADDI X11, X6, #48    // Convert j to ASCII  
			putchar X11          // Print j
			ADDI X11, XZR, #10   // Newline
			putchar X11
			
			LSL X7, X5, #3
			LSL X8, X6, #3
			ADD X9, X5, X6
			LSL X9, X9, #3
			ADD X10, X20, X7
			ADD X11, X21, X8
			ADD X12, X19, X9
			LDUR X13, [X10, #0]
			LDUR X14, [X11, #0]
			LDUR X15, [X12, #0]
			MUL X16, X13, X14
			ADD X17, X15, X16
			STUR X17, [X12, #0]
			
			ADDI X6, X6, #1
			B jloopNM
		
		jloopendNM:
			ADDI X5, X5, #1
			B iloopNM
	
	force_exit:
	iloopendNM:
		LDUR X19, [SP, #0]
		LDUR X20, [SP, #8]
		LDUR X21, [SP, #16]
		LDUR LR, [SP, #24]
		ADDI SP, SP, #32
		
		br lr

TestMult:
	subi  sp, sp, #16
	stur  lr, [sp, #0]
	stur  fp, [sp, #8]
	addi  fp, sp, #8

	lda  x2, array_P
	lda  x1, array_Q
	lda  x0, array_R
	lda  x3, k
	ldur x3, [x3, #0]	// load the k value
	stur x3, [sp, #0]	// store k
	bl NaiveMult		// comment this to test Karatsuba's
	// bl KaratsubaMult	// uncomment this to test Karatsuba's

	// Prepare to print
	lda x1, array_R
	ldur x2, [sp, #0]	// load k
	lsl  x2, x2, #1		// x3 gets 2k
	addi x2, x2, #1		// x3 gets 2k+1
	addi x3, xzr, #32	// x8 gets the whitespace char
	bl PrintResult

	ldur  lr, [sp, #0]
	ldur  fp, [sp, #8]
	addi  sp, sp, #16
	br lr

TestPrint:
	subi  sp, sp, #16
	stur  lr, [sp, #0]
	stur  fp, [sp, #8]
	addi  fp, sp, #8

	lda   x1, array_C
	addi  x2, xzr, #7	// print 7 elements from it
	addi  x3, xzr, #44	// 44 is ASCII for ,
	bl PrintResult

	ldur  lr, [sp, #0]
	ldur  fp, [sp, #8]
	addi  sp, sp, #16
	br lr

// input:
// x1: address to array to print
// x2: number of elements to print
// x3: ASCII delimiter character
PrintResult:
	ldur  x11, [x1, #0]
	putint x11
	putchar x3
	addi  x1, x1, #8
	subis x2, x2, #1
	b.gt  PrintResult
	ldur  x11, [x1, #0]
	putint x11
	br lr
