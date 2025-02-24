.globl my_var
.globl increment_my_var

.section .data
my_var: .word 10

.section .text
increment_my_var:
    /**
    * Incrementa 1 no valor de my_var
    *
    * Retorno:
    * void
    */
    lw a0, my_var
    la a1, my_var
    addi a0, a0, 1
    sw a0, 0(a1)

    ret
