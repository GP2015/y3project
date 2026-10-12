_start:
    lui   t0, 0x10000
    li    t1, 0
loop:
    xori  t1, t1, 1
    sw    t1, 0(t0)
    li    t2, 1000000
delay:
    addi  t2, t2, -1
    bnez  t2, delay
    j     loop
