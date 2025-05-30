main:
    bl TestMult
    stop

InitZeros:
    ADDI X9, XZR, #0
    ORR X11, X0, XZR
    ADDI X10, XZR, #0
    
loop:	
    STUR X10,[X11, #0]
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
    
    // Temporarily skip InitZeros to isolate the issue
    // LSL X4, X3, #1
    // ADDI X4, X4, #1
    // ADDI X1, X4, #0
    // BL InitZeros
    
    ADDI X5, XZR, #0
    
iloopNM:
    SUBS XZR, X5, X3
    B.GT iloopendNM
    
    ADDI X6, XZR, #0
    
jloopNM:
    SUBS XZR, X6, X3
    B.GT jloopendNM
    
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
    
iloopendNM:
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
    ldur x2, [sp, #0]
    lsl  x2, x2, #1
    addi x2, x2, #1
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
