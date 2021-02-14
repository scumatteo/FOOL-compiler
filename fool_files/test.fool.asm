push 0
lfp
push function0
lfp
push 6
push 5
lfp
push -2
add
stm
ltm
lw
ltm
push 1
sub
lw
js
print
halt

function0:
cfp
lra
lfp
push 1
add
lw
lfp
push 2
add
lw
lfp
push -2
add
lw
lfp
push -3
add
lw
lfp
push 1
add
lw
mult
add
stm
pop
pop
sra
pop
pop
pop
sfp
ltm
lra
js
