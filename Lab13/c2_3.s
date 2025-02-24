.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

.section .text
fill_array_int:
    /**
    * Preenche um array de 100 posições com o índice em cada posição
    *
    * Retorno:
    * Chamada da função "mystery_function_int"
    */
    addi sp, sp, -416   # Aloca espaço para o vetor
    sw ra, 400(sp)      # Salva o ra na pilha
    mv a0, sp           # Coloca o endereço de início do vetor
    li t0, 0            # Contador (int i = 0)
    li t1, 100          # Condição de parada do for (número de iterações)

    1:
        bge t0, t1, 2f  # Se já tiver chegado no 100, acabou
        sw t0, 0(a0)    # Se não, coloca o valor do índice na posição
        addi t0, t0, 1  # Incrementa o valor do i
        addi a0, a0, 4  # Vai para a próxima posição do vetor (já que int tem 4 bytes)
        j 1b
    
    2:
        mv a0, sp       # Coloca o endereço de início do vetor em a0
        jal mystery_function_int
        # Recupera o valor de ra e desaloca a pilha
        lw ra, 400(sp)  
        addi sp, sp, 416

    ret


fill_array_short:
    /**
    * Preenche um array de 100 posições com o índice em cada posição
    *
    * Retorno:
    * Chamada da função "mystery_function_short"
    */
    addi sp, sp, -208   # Aloca espaço para o vetor
    sw ra, 200(sp)      # Salva o ra na pilha
    mv a0, sp           # Coloca o endereço de início do vetor
    li t0, 0            # Contador (int i = 0)
    li t1, 100          # Condição de parada do for (número de iterações)

    1:
        bge t0, t1, 2f  # Se já tiver chegado no 100, acabou
        sh t0, 0(a0)    # Se não, coloca o valor do índice na posição
        addi t0, t0, 1  # Incrementa o valor do i
        addi a0, a0, 2  # Vai para a próxima posição do vetor (já que short tem 2 bytes)
        j 1b
    
    2:
        mv a0, sp       # Coloca o endereço de início do vetor em a0
        jal mystery_function_short
        # Recupera o valor de ra e desaloca a pilha
        lw ra, 200(sp)  
        addi sp, sp, 208

    ret


fill_array_char:
    /**
    * Preenche um array de 100 posições com o índice em cada posição
    *
    * Retorno:
    * Chamada da função "mystery_function_char"
    */
    addi sp, sp, -112   # Aloca espaço para o vetor
    sw ra, 100(sp)      # Salva o ra na pilha
    mv a0, sp           # Coloca o endereço de início do vetor
    li t0, 0            # Contador (int i = 0)
    li t1, 100          # Condição de parada do for (número de iterações)

    1:
        bge t0, t1, 2f  # Se já tiver chegado no 100, acabou
        sb t0, 0(a0)    # Se não, coloca o valor do índice na posição
        addi t0, t0, 1  # Incrementa o valor do i
        addi a0, a0, 1  # Vai para a próxima posição do vetor (já que char tem 1 byte)
        j 1b
    
    2:
        mv a0, sp       # Coloca o endereço de início do vetor em a0
        jal mystery_function_char
        # Recupera o valor de ra e desaloca a pilha
        lw ra, 100(sp)  
        addi sp, sp, 112

    ret
