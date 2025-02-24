.globl node_creation

.section .text
node_creation:
    /**
    * Cria um nó e chama a função "mystery_function"
    *
    * Retorno:
    * A chamada de "mystery_function" passando o endereço do nó criado como parâmetro
    */
    # Aloca espaço na pilha e salva o ra
    addi sp, sp, -16
    sw ra, 8(sp)
    mv a0, sp       # Coloca em a0 o endereço do início do nó

    # Carrega os valores de cada nó
    li t0, 30
    li t1, 25
    li t2, 64
    li t3, -12

    sw t0, 0(a0)
    sb t1, 4(a0)
    sb t2, 5(a0)
    sh t3, 6(a0)

    # Chama a função "mystery_function"
    jal mystery_function

    # Recupera o ra e desaloca a pilha
    lw ra, 8(sp)
    addi sp, sp, 16

    ret
