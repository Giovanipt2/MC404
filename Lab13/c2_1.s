.globl swap_int
.globl swap_short
.globl swap_char

.section .text
swap_int:
    /**
    * Troca o valor de duas variáveis inteiras passadas por referência
    *
    * Parâmetros:
    * a0 = endereço da primeira variável
    * a1 = endereço da segunda variável
    *
    * Retorno:
    * 0
    */
    # Carrega os valores das variáveis que estão nesses endereços
    lw t0, 0(a0)
    lw t1, 0(a1)

    # Realiza a troca
    sw t0, 0(a1)
    sw t1, 0(a0)

    li a0, 0

    ret


swap_short:
    /**
    * Troca o valor de duas variáveis do tipo short passadas por referência
    *
    * Parâmetros:
    * a0 = endereço da primeira variável
    * a1 = endereço da segunda variável
    *
    * Retorno:
    * 0
    */
    # Carrega os valores das variáveis que estão nesses endereços
    lh t0, 0(a0)
    lh t1, 0(a1)

    # Realiza a troca
    sh t0, 0(a1)
    sh t1, 0(a0)

    li a0, 0

    ret


swap_char:
    /**
    * Troca o valor de duas variáveis do tipo char passadas por referência
    *
    * Parâmetros:
    * a0 = endereço da primeira variável
    * a1 = endereço da segunda variável
    *
    * Retorno:
    * 0
    */
    # Carrega os valores das variáveis que estão nesses endereços
    lb t0, 0(a0)
    lb t1, 0(a1)

    # Realiza a troca
    sb t0, 0(a1)
    sb t1, 0(a0)

    li a0, 0

    ret
