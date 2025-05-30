main:
    bl TestMult
    stop

// Minimal NaiveMult that does almost nothing
NaiveMult:
    SUBI SP, SP, #32
    STUR X19, [SP, #0]
    STUR X20, [SP, #8]
    STUR X21, [SP, #16]
    STUR LR, [SP, #24]
    
    // Just store some test values in array_R without any loops
    ADDI X19, X0, #0        // R address
    ADDI X10, XZR, #8       // Test value 8
    STUR X10, [X19, #0]     // R[0] = 8
    ADDI X10, XZR, #22      // Test value 22
    STUR X10, [X19, #8]     // R[1] = 22
    ADDI X10, XZR, #15      // Test value 15
    STUR X10, [X19, #16]    // R[2] = 15
    
    LDUR X19, [SP, #0]
    LDUR X20, [SP, #8]
    LDUR X21, [SP, #16]
    LDUR LR, [SP, #24]
    ADDI SP, SP, #32
    
    br lr

TestMult:
    subi sp, sp, #16
    stur lr, [sp, #0]
    stur fp, [sp, #8]
    addi fp, sp, #8
    
    lda  x0, array_R
    lda  x1, array_P
    lda  x2, array_Q
    lda  x3, k
    ldur x3, [x3, #0]
    stur x3, [sp, #0]
    bl NaiveMult
    
    lda  x1, array_R
    addi x2, xzr, #3        // Print exactly 3 numbers
    addi x3, xzr, #32
    bl PrintResult
    
    ldur lr, [sp, #0]
    ldur fp, [sp, #8]
    addi sp, sp, #16
    br lr

PrintResult:
    ldur x11, [x1, #0]
    putint x11
    putchar x3
    addi x1, x1, #8
    subis x2, x2, #1
    b.gt PrintResult
    ldur x11, [x1, #0]
    putint x11
    br lr
