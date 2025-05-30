//////////////////////////
//											//
//	Project Submission								//
//											//
//////////////////////////

// Partner 1: (your name here), (Student ID here)
// Partner 2: (your name here), (Student ID here)

//////////////////////////
//											//
//	main										//
//											//
//////////////////////////
main:

	bl TestPrint
	stop

	bl TestMult		// Uncomment to test Naive implementation first
	// stop 

	// Test the partitioned algoirthm 
	lda  x2, array_D
	lda  x1, array_C
	lda  x0, array_R
	bl MakeCumulative	// x3 gets k
	stur x3, [sp, #0]	// store k
	ldur x5, [x2, #8]	// x5 gets I[1]
	subi x5, x5, #1		// x5 gets I[1]-1, i.e., the degree
	stur x5, [sp, #8]	// store d
	bl BinaryPartitioning	// x4 gets the address for results
	
	ldur x3, [sp, #0]	// load k
	ldur x5, [sp, #8]	// load d
	// Prepare to call print
	addi x1, x4, #0		// x1 gets address of result array
	mul  x2, x3, x5		// x2 gets k*d, the degree of the product
	addi x2, x2, #1		// x2 gets k*d+1, the number of terms in the product
	addi x3, xzr, #32	// x3 gets the whitespace char for the delimiter
	bl PrintResult

stop

	
//////////////////////////
//											//
//	InitZeros									//
//											//
//////////////////////////
InitZeros:
	// input:
	// x0: address of (pointer to) the first symbol of input array
	// output:
	// x1: value specifying the number of values that will be set to 0
 
	ADDI X1, X1, #1
	ADDI X9, XZR, #0
	ORR X11, X0, XZR
	ADDI X10, XZR, #0
	
loop:	STUR X10,[X11, #0]
	ADDI X9, X9, #1
	ADDI X11, X11, #8
	SUBS XZR, X9, X1
	B.LT loop
 
	br lr


//////////////////////////
//											//
//	MakeCumulative									//
//											//
//////////////////////////
MakeCumulative:
	// input:
	// x2: address to the first degree of the array D
	// output:
	// x3: value of the total number of polynomials in the input, k
	// ...
	// Implement this part
	// ...

	ADDI X3, XZR, #0 //i=0
	LSL X9, X3, #3
	ADD X10, X2, X9 //D[0] ref
	LDUR X11, [X10, #0] //c
	STUR XZR, [X10, #0] //D[0]=0
	loopcheck:
	LSL X9, X3, #3
	LDUR X12, [X10, 0]
	ADDIS XZR, X10, #1//compare D[i] to -1
	B.EQ loopend
	ADDI X13, X12, #1//+1
	ADD X13, X13, X11//+c
	STUR X12, [X10, 0]//D[i]val=D[i]val+c+1
	ADDI X11, X12, #0 //c=D[i+1] val
	ADDI X3, X3, #1//i=i+1
	B loopcheck
	loopend:

	br lr


//////////////////////////
//											//
//	ComputeAuxiliary								//
//											//
//////////////////////////
ComputeAuxiliary:
	// input:
	// x1: address of the first coefficient of the input polynomial
	// x2: degree value of the input polynomial
	// x3: address to save the result p1(x)+p2(x)
	// output:
	// This function does not return anything.
	// ...
	// Implement this part
	// ...
	br lr


//////////////////////////
//											//
//	NaiveMult									//
//											//
//////////////////////////
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
	
	ADDI X1, X4, #0 //InitZero takes (R,dr) and R is already in X0, this movs dr to X1
	BL InitZeros //InitZeros func call

	ADDI X5, XZR, #0 //i=0

	iloopNM:
	
	SUBS XZR, X5, X3 //check i with d
	B.GT iloopendNM //end loop if i>d

	ADDI X6, XZR, #0 //j=0

	jloopNM:

	SUBS XZR, X6, X3 //check j with d
	B.GT jloopendNM //end loop if j>d

	LSL X7, X5, #3 //byte index i
	LSL X8, X6, #3 //byte index j
	ADD X9, X7, X8 //byte indexed i+j

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

	LDUR X19, [SP, #0] //restore X19-X21,LR regs
	LDUR X20, [SP, #8]
	LDUR X21, [SP, #16]
	LDUR LR, [SP, #24]
	ADDI SP, SP, #32 //dealloc stack
		
	br lr


//////////////////////////
//											//
//	KaratsubaMult									//
//											//
//////////////////////////
KaratsubaMult:
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
	br lr


//////////////////////////
//											//
//	BinaryPartitioning	//
//											//
//////////////////////////
BinaryPartitioning:
	// input:
	// x0: address to write the intermediate results
	// x1: address of the first value in the input coefficient array
	// x2: address of the first value in the cumulative index array
	// x3: value of the total number of polynomials to multiply, k
	// output:
	// x4: the address of the results (i.e., first value in the left split of C)
	// ...
	// Implement this part
	// ...

	SUBI SP, SP, #80 //allocate mem on the stack to temp store reg X0 through X9 and LR
	STUR X19, [SP, #0]
	STUR X20, [SP, #8]
	STUR X21, [SP, #16]
	STUR X22, [SP, #24]
	STUR X23, [SP, #32]
	STUR X24, [SP, #40]
	STUR X25, [SP, #48]
	STUR X26, [SP, #56]
	STUR X27, [SP, #64]
	STUR LR, [SP, #72]

	ADDI X19, X0, #0 //save passed values in calleesave regs
	ADDI X20, X1, #0
	ADDI X21, X2, #0
	ADDI X22, X3, #0

	LSR X23, X3, #1 // l=k/2
	
	SUBIS XZR, X22, #2 //check k=2 
	B.NE elsecondBP //if k+2 continue, else branch
	
	LDUR X9, [X20, #0] //load C val
	LDUR X10, [X21, #0] //load I[0] val
	LSL X10, X10, #3 //covert I[0] val to byte index
	ADD X24, X9, X10 // C1=C+I[0]
	LDUR X10, [X21, #8] //load I[1] val
	LSL X10, X10, #3 //covert I[0] val to byte index
	ADD X25, X5, X7 // C2=C+I[1]
	
	ADDI X4, X24, #0 //return C1 to X4
	B BPifend

	elsecondBP:	
	ADDI X0, X19, #0 // reassign passed vals to reg x0-x3
	ADDI X1, X20, #0 
	ADDI X2, X21, #0
	ADDI X3, X23, #0 //instead of initial X3 val use val of l
	
	BL BinaryPartitioning //1st recursive func call
	ADDI X24, X4, #0 //save return as C1 val
	
	ADDI X0, X19, #0 // reassign passed vals to reg x0-x3
	ADDI X1, X20, #0
	LSL X9, X23, #3 // byte index l 
	ADD X2, X21, X9 //I+l
	ADDI X3, X23, #0 //instead of initial X3 val use val of l
	
	BL BinaryPartitioning //1st recursive func call
	ADDI X25, X4, #0 //save return as C2 val
	
	BPifend: //continatuion after if/else
	
	LDUR X9, [X21, #0]
	LDUR X10, [X21, #8]
	SUB X11, X10, X9 // I[1]-I[0] part of dn=l(I1-I0-1)
	SUBI X11, X11, #1 // -1 part of above
	MUL X26, X23, X11 //l* part of above where X26 = dn

	LSL X27, X26, #1 //dr=2*dn

	ADDI X0, X19, #0 //assign R, C1, C2, dn to X0-X3 to pass into NaiveMult
	ADDI X1, X24, #0
	ADDI X2, X25, #0
	ADDI X3, X27, #0

	BL NaiveMult //NaiveMult func call
	
	ADDI X28, XZR, #0 //i = 0
	
	loopR1C1: //loop reentrance
	
	SUBS XZR, X28, X27 //check for i>dr
	B.GT loopendR1C1 //end loop if i>dr

	LSL X9, X28, #3 //byte index i
	ADD X10, X19, X9 //address R[i]
	ADD X11, X20, X9 //address C1[i]
	LDUR X12, [X10, #0] //val R[i]
	STUR X12, [X11, #0] //assign val of R[i] to C1[i]
	
	ADDI X28, X28, #1 //i++
	B loopR1C1 //start loop again

	loopendR1C1: //end of loop 
	
	ADDI X4, X24, #0 //return C1 to X4
	
	LDUR X19, [SP, #0] //restore values from stack
	LDUR X20, [SP, #8]
	LDUR X21, [SP, #16]
	LDUR X22, [SP, #24]
	LDUR X23, [SP, #32]
	LDUR X24, [SP, #40]
	LDUR X25, [SP, #40]
	LDUR X26, [SP, #48]
	LDUR X27, [SP, #56]
	LDUR X28, [SP, #64]
	LDUR LR, [SP, #72]
	ADDI SP, SP, #80 //deallocate stack mem

	br lr // end of BP


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
	addi x0, x1, #0		// load output array pointer to x0
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

