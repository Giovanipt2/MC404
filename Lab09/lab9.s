.globl _start
.globl gets
.globl puts
.globl linked_list_search
.globl atoi
.globl itoa
.globl exit

.section .bss
input: .skip 7      # Buffer de entrada
output: .skip 5     # Buffer de saída

.section .data
new_line_char: .byte '\n'    # Caractere de nova linha

.section .text
gets:
    /**
    * Lê a string de entrada
    *
    * Parametros:
    * a0 = ponteiro para o buffer de entrada
    * 
    * Retorno:
    * Endereço para o buffer preenchido
    * Troca o último caractere por '\0'
    */
    mv a1, a0           # Guarda o endereço do buffer de entrada
    li a0, 0            # file descriptor = 0 (stdin)
    li a2, 7            # size
    li a7, 63           # syscall read (63)
    ecall

    ret


puts:
    /**
    * Escreve a string de saída
    *
    * Parametros:
    * a0 = ponteiro para a string de saída (terminada em '\0')
    * Troca o último caractere por '\n'
    *
    * Retorno:
    * void
    */
    mv a1, a0           # Guarda o endereço da string de saída
    li a0, 1            # file descriptor = 1 (stdout)
    li a2, 5            # size
    li a7, 64           # syscall write (64)
    ecall

    ret


exit:
    /**
    * Finaliza a execução do programa
    *
    * Parametros:
    * a0 = código de retorno
    *
    * Retorno:
    * void
    */
    li a7, 93
    ecall
    ret


atoi:
    /**
    * Converte uma string para um número inteiro
    *
    * Parâmetros:
    * a0 = ponteiro para a string de entrada
    *
    * Retorno:
    * a0 = Número inteiro convertido
    */
    li t4, '-'  # Usado para que se possa fazer a comparação
    li t0, '\n'     # Para identificar o final do número
    li t2, 10       # Carrega o imediato 10 em t2
    mv a1, a0       # Guarda o endereço da string de entrada em a1
    li a0, 0    # O número que será retornado
    li t3, 0    # Flag para número negativo (0 = positivo, 1 = negativo)

    # Verifica se o primeiro caractere é um sinal de -
    lb a2, 0(a1)            # Lê o primeiro caractere (sinal)
    beq a2, t4, negative1   # Se for '-', vá para negativo
    j 1f                    # Se não for '-', vá para a conversão dos dígitos

    negative1:
        li t3, 1        # Marca como número negativo
        addi a1, a1, 1  # Pula o caractere '-'

    1:
        lb a2, 0(a1)       # Guarda o dígito lido em a2
        beq a2, t0, 2f      # Se for '\0', pule para o final
        addi a2, a2, -'0'   # Transformando para inteiro
        mul a0, a0, t2      # Multiplica por 10 para corrigir o decimal
        add a0, a0, a2      # Soma o número inteiro lido em  a0 
        addi a1, a1, 1      # Para ir para o próximo dígito a ser lido
        j 1b                # Volta para a próxima iteração

    # Aplica o sinal negativo, se necessário
    2:
        beqz t3, end1       # Se t3 == 0 (positivo), pule para o final
        neg a0, a0          # Se t3 == 1 (negativo), inverte o sinal de a0

    end1:
        ret


itoa:
    /**
    * Converte um número inteiro para uma string
    *
    * Parâmetros:
    * a0 = número inteiro a ser convertido
    * a1 = ponteiro para a string de saída
    * a2 = base numérica usada na conversão
    *
    * Retorno:
    * Endereço para a string de saída
    * A string de saída é terminada em '\0'
    */  
    li t0, '\n'     # Para identificar o final da string
    li t1, '-'      # Para identificar o sinal negativo
    li t2, 2        # Para sabermos se devemos inverter o número

    # Verifica se o número é negativo
    bltz a0, negative2  # Se for negativo, vá para negativo
    j conversion        # Se não for negativo, vá para a conversão dos dígitos

    negative2:
        sb t1, 0(a1)    # Coloca o sinal negativo na string
        addi a1, a1, 1  # Pula o caractere '-'
        neg a0, a0      # Inverte o sinal do número

    conversion:
        mv a3, a1       # Guarda o endereço de início da string de saída em a3
        li t3, 0        # Contador de dígitos

        # Converte o número para string
        1:
            rem t4, a0, a2      # Calcula o resto da divisão do número por 10
            div a0, a0, a2      # Divide o número que se tinha por 10 para a próxima iteração
            addi t4, t4, '0'    # Converte o número para um caractere
            sb t4, 0(a1)        # Carrega o dígito em questão na sua posição da saída
            addi a1, a1, 1      # Vai para o próximo caractere
            addi t3, t3, 1      # Incrementa o contador de dígitos
            bnez a0, 1b         # Vai para a próxima iteração do loop

        sb t0, 0(a1)            # Coloca o caractere nulo no final da string
        # Inverte a string
        addi a1, a1, -1         # Volta para o último caractere
        blt t3, t2, end2          # Se há mais do que dois dígitos, inverte a ordem
        srli t3, t3, 1      # Divide o contador de dígitos por 2

        2:
            # Quantas vezes eu terei que fazer a troca de caracteres
            lb t4, 0(a1)        # Carrega o caractere da última posição
            lb t5, 0(a3)        # Carrega o caractere da primeira posição
            sb t5, 0(a1)        # Troca o caractere da posição atual
            sb t4, 0(a3)        # Troca o caractere da posição oposta
            addi a1, a1, -1     # Vai para o próximo caractere
            addi a3, a3, 1      # Vai para o próximo caractere
            addi t3, t3, -1     # Decrementa o contador de trocas
            bnez t3, 2b         # Se ainda não terminou, volte para a próxima iteração

    end2:
        ret


linked_list_search:
    /*
    * Busca o nó cuja soma dos valores é igual ao valor a ser buscado
    *
    * Parâmetros:
    * a0 = ponteiro para o início da lista
    * a1 = valor a ser buscado
    *
    * Retorno:
    * a0 = o índice do nó que contém o valor buscado
    * Caso o valor não seja encontrado, a0 = -1
    */
    li t0, 0        # "int i = 0" contador de nós (índice)
    li t1, 0        # "int sum = 0" (para a soma dos valores)
    
    1:
        lw t2, 0(a0)    # Carrega o valor 1 do primeiro nó
        lw t3, 4(a0)    # Carrega o valor 2 do primeiro nó
        lw t4, 8(a0)    # Carrega o endereço do próximo nó

        add t1, t2, t3          # Soma os valores do primeiro nó
        beq t1, a1, search_end  # Se a soma for igual ao valor buscado, vá para o final
        beqz t4, not_found      # Se o índice do próximo nó for 0, a lista acabou
        addi t0, t0, 1          # Incrementa o contador de nós
        mv a0, t4               # Passa para o próximo nó
        j 1b                    # Volta para a próxima iteração

    not_found:
        li a0, -1
        ret

    search_end:
        mv a0, t0       # Retorna o índice do nó que contém o valor buscado em a0
        ret


_start:
    # Lê a entrada do programa
    la a0, input
    jal ra, gets

    # Converte a entrada para inteiro
    la a0, input
    jal ra, atoi

    # Busca o valor na lista ligada
    mv a1, a0       # Passa o valor lido da entrada e convertido para inteiro
    la a0, head_node
    jal ra, linked_list_search

    # Converte o valor para string
    la a1, output
    li a2, 10           # Base numérica
    jal ra, itoa

    # Escreve a saída
    la a0, output
    jal ra, puts

    # End (marca o fim da execução do programa)
    li a0, 0
    jal ra, exit
