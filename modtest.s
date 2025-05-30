main:
    bl TestMult
    stop

// Safe InitZeros with bounds checking
InitZeros:
    // Safety check - prevent initializing too many elements
    SUBI X28, X1, #50       // Check if count > 50
    B.LE init_safe
    ADDI X1, XZR, #10       // Cap at 10 elements for safety
init_safe:
    ADDI X9, XZR, #0        // counter = 0
    ORR X11, X0, XZR        // copy array address
    ADDI X10, XZR, #0       // value to store (0)
    
init_loop:
    STUR X10, [X11, #0]     // store 0
    ADDI X9, X9, #1         // counter++
    ADDI X11, X11, #8       // next address
    SUBS XZR, X9, X1        // compare counter with limit
    B.LT init_loop          // continue if counter < limit
    
    br lr

// Rewritten NaiveMult with safety checks and cleaner loop structure
NaiveMult:
    // Save registers - use standard 32-byte allocation
    SUBI SP, SP, #32
    STUR X19, [SP, #0]
    STUR X20, [SP, #8]
    STUR X21, [SP, #16]
    STUR LR, [SP, #24]
    
    // Save parameters
    ADDI X19, X0, #0        // R (output array)
    ADDI X20, X1, #0        // P (first polynomial)
    ADDI X21, X2, #0        // Q (second polynomial)
    // Use X3 directly for degree (don't save in X22)
    
    // Safety check on degree
    SUBI X28, X3, #10       // Check if degree > 10
    B.LE degree_safe
    ADDI X3, XZR, #3        // Cap degree at 3 for safety
degree_safe:
    
    // Calculate number of result coefficients: 2d + 1
    LSL X4, X3, #1          // 2d
    ADDI X4, X4, #1         // 2d + 1
    
    // Initialize result array
    ADDI X0, X19, #0        // R address
    ADDI X1, X4, #0         // number of elements to initialize
    BL InitZeros
    
    // Outer loop: i from 0 to d
    ADDI X5, XZR, #0        // i = 0
    
outer_loop:
    SUBS XZR, X5, X3        // compare i with d
    B.GT outer_done         // exit if i > d
    
    // Inner loop: j from 0 to d (reset j for each i)
    ADDI X6, XZR, #0        // j = 0
    
inner_loop:
    SUBS XZR, X6, X3        // compare j with d
    B.GT inner_done         // exit if j > d
    
    // Calculate array indices and addresses
    LSL X7, X5, #3          // i * 8 (byte offset)
    LSL X8, X6, #3          // j * 8 (byte offset)
    ADD X9, X5, X6          // i + j (result index)
    LSL X9, X9, #3          // (i + j) * 8 (byte offset)
    
    ADD X10, X20, X7        // &P[i]
    ADD X11, X21, X8        // &Q[j]
    ADD X12, X19, X9        // &R[i+j]
    
    // Load values
    LDUR X13, [X10, #0]     // P[i]
    LDUR X14, [X11, #0]     // Q[j]
    LDUR X15, [X12, #0]     // R[i+j]
    
    // Multiply and accumulate: R[i+j] = R[i+j] + P[i] * Q[j]
    MUL X16, X13, X14       // P[i] * Q[j]
    ADD X17, X15, X16       // R[i+j] + P[i] * Q[j]
    STUR X17, [X12, #0]     // Store result
    
    // Increment j and continue inner loop
    ADDI X6, X6, #1         // j++
    B inner_loop
    
inner_done:
    // Increment i and continue outer loop
    ADDI X5, X5, #1         // i++
    B outer_loop
    
outer_done:
    // Restore registers
    LDUR X19, [SP, #0]
    LDUR X20, [SP, #8]
    LDUR X21, [SP, #16]
    LDUR LR, [SP, #24]
    ADDI SP, SP, #32
    
    br lr

// TestMult function
TestMult:
    subi sp, sp, #24
    stur lr, [sp, #0]
    stur fp, [sp, #8]
    stur x19, [sp, #16]      // Save degree for printing
    addi fp, sp, #8
    
    // Load arrays and degree
    lda  x0, array_R         // Output array
    lda  x1, array_P         // First polynomial
    lda  x2, array_Q         // Second polynomial
    lda  x3, k               // Degree address
    ldur x3, [x3, #0]        // Load degree value
    addi x19, x3, #0         // Save degree
    
    // Call NaiveMult
    bl NaiveMult
    
    // Prepare to print results
    lda  x1, array_R         // Array to print
    lsl  x2, x19, #1         // 2 * degree
    addi x2, x2, #1          // 2 * degree + 1 (number of coefficients)
    addi x3, xzr, #32        // Space character
    bl PrintResult
    
    // Restore and return
    ldur lr, [sp, #0]
    ldur fp, [sp, #8]
    ldur x19, [sp, #16]
    addi sp, sp, #24
    br lr

// PrintResult function
PrintResult:
    // Print all elements except the last with delimiter
print_loop:
    subis x2, x2, #1         // Decrement counter
    b.eq print_last          // If counter is 0, print last element
    
    ldur x11, [x1, #0]       // Load current element
    putint x11               // Print it
    putchar x3               // Print delimiter
    addi x1, x1, #8          // Move to next element
    b print_loop
    
print_last:
    ldur x11, [x1, #0]       // Load last element
    putint x11               // Print it (no delimiter after last)
    br lr

// Test data - start with minimal case
// For testing k=1: (2+3x) * (4+5x) = 8+22x+15x^2
// Expected output: 8 22 15

// Uncomment the test case you want to use:

// Test Case 1: k=1 (should work)
// k: 1
// array_P: 2, 3
// array_Q: 4, 5  
// array_R: 0, 0, 0, 0, 0

// Test Case 2: k=2 (test this after k=1 works)
// k: 2
// array_P: 1, 2, 3
// array_Q: 4, 5, 6
// array_R: 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

// Test Case 3: k=5 (original test - try this last)
// k: 5
// array_P: 4, 1, 2, 3, 3, 6
// array_Q: 1, 1, 1, 1, 1, 1
// array_R: 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
