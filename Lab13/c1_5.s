.globl operation

.section .text
operation:
    /**
    * Coloca os parâmetros recebidos na ordem correta para chamar "mystery_function"
    */
    # Aloca espaço na pilha e salva o ra
    addi sp, sp, -64
    sw ra, 32(sp)   
    sw fp, 28(sp)   # Salva o frame pointer anterior
    addi fp, sp, 64 # Ajusta o frame pointer para o quadro atual

    # Salva os primeiros parâmetros passados
    mv t0, a0   # a (primeiro parâmetro)
    mv t1, a1   # b (segundo parâmetro)
    mv t2, a2   # c (terceiro parâmetro)
    mv t3, a3   # d (quarto parâmetro)
    mv t4, a4   # e (quinto parâmetro)
    mv t5, a5   # f (sexto parâmetro)
    mv t6, a6   # g (sétimo parâmetro)
    sw a7, 24(sp)   # h (oitavo parâmetro)

    # Pega os demais parâmetros (passados pela pilha)
    lw a0, 20(fp)   # n (décimo quarto parâmetro)
    lw a1, 16(fp)   # m (décimo terceiro parâmetro)
    lw a2, 12(fp)   # l (décimo segundo parâmetro)
    lw a3, 8(fp)    # k (décimo primeiro parâmetro)
    lw a4, 4(fp)    # j (décimo parâmetro)
    lw a5, 0(fp)    # i (nono parâmetro)

    # Passa os parâmetros corretamente para "mystery_function"
    lw a6, 24(sp)
    mv a7, t6
    sw t0, 20(sp)
    sw t1, 16(sp)
    sw t2, 12(sp)
    sw t3, 8(sp)
    sw t4, 4(sp)
    sw t5, 0(sp)

    jal mystery_function

    # Recupera o ra, o fp anterior e desaloca a pilha
    lw ra, 32(sp)
    lw fp, 28(sp)
    addi sp, sp, 64

    ret
