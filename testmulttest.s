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
	// input:
	// x0: address to write the coefficients of the resulting product
	// x1: address to the first coefficient in p(x)
	// x2: address to the first coefficient in q(x)
	// x3: the value of the degrees of p(x) and q(x), d
	// output:
	// This function does not return anything.
	// ...
	// Implement this part
	// ...
	
	SUBI SP, SP, #32 //alloc stack for X19-X21,LR
	STUR X19, [SP, #0]
	STUR X20, [SP, #8]
	STUR X21, [SP, #16]
	STUR LR, [SP, #24]
	
	ADDI X19, X0, #0 //saved passed in vals in X19-X21, d doesnt need to be saved as it will not be changed
	ADDI X20, X1, #0 
	ADDI X21, X2, #0	

	LSL X4, X3, #1 //dr=2d
	ADDI X4, X4, #1	
	ADDI X1, X4, #0 //InitZero takes (R,dr) and R is already in X0, this movs dr to X1
	BL InitZeros //InitZeros func call

	ADDI X5, XZR, #0 //i=0
	ADDI X28, XZR, #0 //safety counter - ADD THIS

	iloopNM:
	ADDI X28, X28, #1 //increment counter - ADD THIS
	SUBI X29, X28, #20 //check if > 20 iterations - ADD THIS  
	B.GT iloopendNM //force exit - ADD THIS

	SUBS XZR, X5, X3 //check i with d
	B.GT iloopendNM //end loop if i>d


	jloopNM:

	SUBS XZR, X6, X3 //check j with d
	B.GT jloopendNM //end loop if j>d

	LSL X7, X5, #3 //byte index i
	LSL X8, X6, #3 //byte index j
	ADD X9, X5, X6 //i+j	
	LSL X9, X9, #3 //i+j byte indexed

	ADD X10, X20, X7 //mem address P[i]
	ADD X11, X21, X8 //mem address Q[j]
	ADD X12, X19, X9 //mem address R[i+j]

	LDUR X13, [X10, #0] //P[i] val
	LDUR X14, [X11, #0] //Q[i] val
	LDUR X15, [X12, #0] //R[i+j] val

	MUL X16, X13, X14 //val P[i]*Q[j]
	ADD X17, X15, X16 //val R[i+j]+P[i]*Q[j]
	STUR X17, [X12, #0] //put above val in R[i+j] address

	ADDI X6, X6, #1 //j++
	B jloopNM
	
	jloopendNM:

	ADDI X5, X5, #1 //i++
	B iloopNM

	iloopendNM:

	LDUR X19, [SP, #0] //restore X19-X21,LR regs
	LDUR X20, [SP, #8]
	LDUR X21, [SP, #16]
	LDUR LR, [SP, #24]
	ADDI SP, SP, #32 //dealloc stack
		
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
