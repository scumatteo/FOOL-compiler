push 0
lfp
push function0
lfp
push function1
lfp
push 2
lfp
push -4
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
push 7
push 5
lfp
push 2
add
stm
ltm
lw
ltm
push 1
sub
lw
js
stm
sra
pop
pop
pop
sfp
ltm
lra
js

function2:
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
add
lfp
lw
push 1
add
lw
mult
stm
sra
pop
pop
pop
sfp
ltm
lra
js

function1:
cfp
lra
lfp
push function2
lfp
lfp
push -6
add
lw
lfp
push -6
push 1
sub
add
lw
lfp
lw
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
stm
pop
pop
sra
pop
pop
sfp
ltm
lra
js
