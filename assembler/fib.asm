MOV #13, R0
INC R1
my_loop: MOV R1, R2
ADD R0, R1
MOV R2, R0
BNE my_loop
