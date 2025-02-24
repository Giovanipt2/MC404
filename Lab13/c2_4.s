.globl node_op

.section .text
node_op:
    /**
    * Realiza a operação: node->a + node->b - node->c + node->d
    *
    * Parâmetros:
    * a0 = ponteiro para um nó da strcut Node
    *
    * Retorno:
    * Resultado da operação descrita acima
    */
    # Carrega os valores de cada campo do nó
    lw t0, 0(a0)    # int a
    lb t1, 4(a0)    # char b
    lb t2, 5(a0)    # char c
    lh t3, 6(a0)    # short d

    # Computa a operação
    add a0, t0, t1
    sub a0, a0, t2
    add a0, a0, t3

    ret
