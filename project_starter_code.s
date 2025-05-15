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

	//bl TestMult		// Uncomment to test Naive implementation first
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
	// ...
	// Implement this part
	// ...
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

