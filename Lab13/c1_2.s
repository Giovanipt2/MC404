.globl my_function

.section .text
my_function:
    /**
    * Essa função realiza as seguintes operações:
    * Soma os dois primeiros valores (SUM 1)
    * Chama "mystery_function" passando a soma anterior e o primeiro valor como parâmetros (CALL 1)
    * Calcula a diferença entre o segundo valor e o retorno dessa função (DIFF 1)
    * Soma o terceiro valor a essa diferença (SUM 2)
    * Chama "mystery_function" passando, como parâmetros, a soma acima e o segundo valor (CALL 2)
    * Calcula a diferença entre o terceiro valor e o retorno dessa função (DIFF 2)
    * Soma a diferença acima com a soma do terceiro valor e da primeira diferença, ou seja, com SUM 2 (SUM 3)
    * Retorna SUM 3
    *
    * Parâmetros:
    * a0 = a (primeiro valor)
    * a1 = b (segundo valor)
    * a2 = c (terceiro valor)
    *
    * Retorno:
    * a0 = valor de SUM 3
    */
    # Não é usado fp (s0) pois só podemos usar registradores "caller saved"
    addi sp, sp, -32    # Aloca o quadro de pilha dessa rotina (múltiplo de 16)
    sw a0, 12(sp)
    sw a1, 8(sp)
    sw a2, 4(sp)
    sw ra, 0(sp)

    # SUM 1
    add a0, a0, a1 

    # CALL 1
    lw a1, 12(sp)
    jal mystery_function

    # DIFF 1
    lw a1, 8(sp)
    sub a0, a1, a0

    # SUM 2
    lw a2, 4(sp)
    add a0, a2, a0
    sw a0, 16(sp)   # Guarda o valor de SUM 2 na pilha

    # CALL 2
    lw a1, 8(sp)
    jal mystery_function

    # DIFF 2
    lw a2, 4(sp)
    sub a0, a2, a0

    # SUM 3
    lw a1, 16(sp)
    add a0, a0, a1

    # Recuperando os valores e desalocando a pilha
    lw ra, 0(sp)
    addi sp, sp, 32

    ret
