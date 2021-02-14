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
lfp
push function0
lfp
push function2
lfp
push function3
lfp
push function5
push 2
push 1
push 4
push 3
push 2
push 5
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
lfp
push -11
add
lw
lfp
push -9
add
stm
ltm
lw
ltm
push 1
sub
lw
js
lfp
push -3
add
stm
ltm
lw
ltm
push 1
sub
lw
js
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

function1:
cfp
lra
lfp
push 2
add
lw
lfp
push 1
add
lw
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
stm
sra
pop
pop
pop
sfp
ltm
lra
js

function0:
cfp
lra
lfp
push function1
lfp
push 1
add
lw
push -1
beq label2
push 0
b label3
label2: 
push 1
label3: 
push 1
beq label0
lfp
lfp
lfp
push 1
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
print
lfp
lfp
lfp
push 1
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
lw
push -3
add
stm
ltm
lw
ltm
push 1
sub
lw
js
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
b label1
label0: 
push -1
label1: 
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

function2:
cfp
lra
lfp
push 1
add
lw
push -1
beq label6
push 0
b label7
label6: 
push 1
label7: 
push 1
beq label4
lfp
lfp
push 1
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
push 2
add
lw
lfp
lfp
push 1
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
lw
push -5
add
stm
ltm
lw
ltm
push 1
sub
lw
js
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
b label5
label4: 
lfp
push 2
add
lw
label5: 
stm
sra
pop
pop
pop
sfp
ltm
lra
js

function4:
cfp
lra
lfp
lw
push 3
add
lw
push 1
beq label8
push 1
lfp
push 1
add
lw
sub
b label9
label8: 
lfp
push 1
add
lw
label9: 
stm
sra
pop
pop
sfp
ltm
lra
js

function3:
cfp
lra
lfp
push function4
lfp
push 1
add
lw
push -1
beq label12
push 0
b label13
label12: 
push 1
label13: 
push 1
beq label10
lfp
lfp
lfp
push 1
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
push 2
add
lw
bleq label16
push 0
b label17
label16: 
push 1
label17: 
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
push 1
beq label14
lfp
lfp
push 3
add
lw
lfp
push 2
add
lw
lfp
lfp
push 1
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
lw
push -7
add
stm
ltm
lw
ltm
push 1
sub
lw
js
b label15
label14: 
lfp
lfp
push 1
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
push 3
add
lw
lfp
push 2
add
lw
lfp
lfp
push 1
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
lw
push -7
add
stm
ltm
lw
ltm
push 1
sub
lw
js
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
label15: 
b label11
label10: 
push -1
label11: 
stm
pop
pop
sra
pop
pop
pop
pop
sfp
ltm
lra
js

function5:
cfp
lra
lfp
push 1
add
lw
push -1
beq label20
push 0
b label21
label20: 
push 1
label21: 
push 1
beq label18
lfp
lfp
push 1
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
b label19
label18: 
push 0
label19: 
lfp
push 1
add
lw
push -1
beq label24
push 0
b label25
label24: 
push 1
label25: 
push 1
beq label22
lfp
lfp
push -2
add
lw
lfp
lfp
push 0
lfp
push -2
add
lw
lfp
lfp
push 1
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
lw
push -7
add
stm
ltm
lw
ltm
push 1
sub
lw
js
lfp
lw
push -9
add
stm
ltm
lw
ltm
push 1
sub
lw
js
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
push 1
lfp
push -2
add
lw
lfp
lfp
push 1
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
lw
push -7
add
stm
ltm
lw
ltm
push 1
sub
lw
js
lfp
lw
push -9
add
stm
ltm
lw
ltm
push 1
sub
lw
js
lfp
lw
push -5
add
stm
ltm
lw
ltm
push 1
sub
lw
js
b label23
label22: 
push -1
label23: 
stm
pop
sra
pop
pop
sfp
ltm
lra
js
