push 0
lhp
push method0
lhp
sw
push 1
lhp
add
shp
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
push method3
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
push method4
lhp
sw
push 1
lhp
add
shp
push 50000
push 40000
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
push 9997
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
push 9995
lw
lhp
sw
lhp
push 1
lhp
add
shp
push 20000
push 5000
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
push 9997
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
push -7
add
lw
lfp
push -6
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
push -8
add
lw
push -1
beq label10
push 0
b label11
label10: 
push 1
label11: 
push 1
beq label8
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
b label9
label8: 
push 0
label9: 
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

method3:
cfp
lra
push 30000
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
add
bleq label2
push 0
b label3
label2: 
push 1
label3: 
push 1
beq label0
push -1
b label1
label0: 
lfp
lfp
lw
push -1
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
label1: 
stm
sra
pop
pop
sfp
ltm
lra
js

method4:
cfp
lra
push 20000
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
bleq label6
push 0
b label7
label6: 
push 1
label7: 
push 1
beq label4
push -1
b label5
label4: 
lfp
lfp
lw
push -1
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
lw
push -1
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
push 9997
lw
lhp
sw
lhp
push 1
lhp
add
shp
label5: 
stm
sra
pop
pop
sfp
ltm
lra
js
