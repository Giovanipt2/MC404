.globl operation

.section .text
operation:
    /**
    * Realiza a operação: b + c - f + h + k - m
    * b = segundo parâmetro (a1)
    * c = terceiro parâmetro (a2)
    * f = sexto parâmetro (a5)
    * h = oitavo parâmetro (a7)
    * k = décimo primeiro parâmetro (8(sp))
    * m = décimo terceiro parâmetro (16(sp))
    */
    # Carrega os parâmetros que foram passados pela pilha
    lw t0, 8(sp)
    lw t1, 16(sp)

    # Realiza a operação pedida
    add a0, a1, a2
    sub a0, a0, a5
    add a0, a0, a7
    add a0, a0, t0
    sub a0, a0, t1

    ret
