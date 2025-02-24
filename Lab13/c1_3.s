.globl operation

.section .text
operation:
    /**
    * Declara variáveis e chama "mystery_function"
    */
    # Aloca espaço na pilha e guarda o ra
    addi sp, sp, -32
    sw ra, 24(sp)

    # Inicializa todas as variáveis locais 
    li a0, 1
    li a1, -2
    li a2, 3
    li a3, -4
    li a4, 5
    li a5, -6
    li a6, 7
    li a7, -8

    li t0, -14
    li t1, 13
    li t2, -12
    li t3, 11
    li t4, -10
    li t5, 9

    # Empilhando os parâmetros que não couberam na pilha de trás para frente
    sw t0, 20(sp)
    sw t1, 16(sp)
    sw t2, 12(sp)
    sw t3, 8(sp)
    sw t4, 4(sp)
    sw t5, 0(sp)

    jal mystery_function

    # Recupera ra e desaloca espaço na pilha
    lw ra, 24(sp)
    addi sp, sp, 32

    ret
