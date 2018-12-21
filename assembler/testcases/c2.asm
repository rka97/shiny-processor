Mov #100, R6
Add #20, R2
Mov R6, @R2 ; [20] = 100
And R2, @R2 ; [20] = 120
Loopa:
Inc R4
Inc R4
NOP
INV R4
CMP R4, R4
BNE Loopa
HLt