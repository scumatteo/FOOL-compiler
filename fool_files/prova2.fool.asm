push 0
lhp
push method0
lhp
sw
push 1
lhp
add
shp
push method1
lhp
sw
push 1
lhp
add
shp
lhp
push method2
lhp
sw
push 1
lhp
add
shp
lfp
push function0
lfp
push function1
push 5
push 3
push -1
lhp 
sw
push 1
lhp
add
shp
lhp 
sw
push 1
lhp
add
shp
push 9998
lw
lhp
sw
lhp
push 1
lhp
add
shp
lhp 
sw
push 1
lhp
add
shp
lhp 
sw
push 1
lhp
add
shp
push 9998
lw
lhp
sw
lhp
push 1
lhp
add
shp
lfp
lfp
push -8
add
lw
stm
ltm
ltm
lw
push 1
add
lw
js
lfp
lfp
lfp
push -9
add
lw
stm
ltm
ltm
lw
push 0
add
lw
js
lfp
lfp
push -8
add
lw
stm
ltm
ltm
lw
push 0
add
lw
js
lfp
push -6
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

method0:
cfp
lra
lfp
lw
push -1
add
lw
stm
sra
pop
sfp
ltm
lra
js

method1:
cfp
lra
lfp
lw
push -2
add
lw
stm
sra
pop
sfp
ltm
lra
js

method2:
cfp
lra
lfp
lw
push -1
add
lw
stm
sra
pop
sfp
ltm
lra
js

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
add
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
lfp
push 2
add
lw
lfp
push 1
add
lw
lfp
lw
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
push 7
add
stm
sra
pop
pop
pop
sfp
ltm
lra
js
