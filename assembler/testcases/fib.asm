; Computes the Fibonacci sequence until overflow.
INC R0
INC R1
fibonacci: MOV R1, R2
ADD R0, R1
MOV R2, R0
BNE fibonacci
