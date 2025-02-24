.globl _start

.section .bss
pos_input: .skip 12
time_imput: .skip 20
output: .skip 12


.section .text
read:
    li a0, 0  # file descriptor = 0 (stdin)
    li a7, 63 # syscall read (63)
    ecall
    ret


write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # Escreve utilizando a string de saída
    li a2, 12           # size
    li a7, 64           # syscall write (64)
    ecall
    ret


str_to_int_sinal:
    li t4, '+'  # Usado para que se possa fazer a comparação
    li t5, '-'  # Usado para que se possa fazer a comparação
    li t0, 0    # "int i = 0" (para o loop)
    la a1, pos_input
    add a1, a1, a0  # Corrige o endereço de início de leitura da string
    li t2, 10       # Carrega o imediato 10 em t2
    li a0, 0    # O número que será retornado
    li a3, 4    # Condição de para do for
    li t3, 0    # Flag para número negativo (0 = positivo, 1 = negativo)

    # Verifica se o primeiro caractere é um sinal (+ ou -)
    lb a2, 0(a1)            # Lê o primeiro caractere (sinal)
    beq a2, t4, 1f          # Se for '+', pule para positivo
    beq a2, t5, negativo    # Se for '-', vá para negativo

    negativo:
        li t3, 1        # Marca como número negativo
        j 1f            # Vai para a conversão dos dígitos

    1:
        lb a2, 1(a1)        # Guarda o dígito lido em a2
        addi a2, a2, -'0'   # Transformando para inteiro
        mul a0, a0, t2      # Multiplica por 10 para corrigir o decimal montado
        add a0, a0, a2      # Soma o número inteiro lido em  a0 
        addi t0, t0, 1      # Incrementa o "i" para o próximo loop
        addi a1, a1, 1      # Para ir para o próximo dígito da iteração
        blt t0, a3, 1b     # Vai para a próxima iteração o loop se "i < 4"

    # Aplica o sinal negativo, se necessário
    beqz t3, end1           # Se t3 == 0 (positivo), pule para o final
    neg a0, a0             # Se t3 == 1 (negativo), inverte o sinal de a0

    end1:
        ret


str_to_int:
    li t0, 0    # "int i = 0" (para o loop)
    la a1, time_imput   # Carrega o endereço da entrada em a1
    add a1, a1, a0  # Corrige o endereço de início de leitura da string
    li t2, 10       # Carrega o imediato 10 em t2
    li a0, 0    # O número que será retornado
    li a3, 4    # Condição de para do for

    1:
        lb a2, 0(a1)    # Guarda o dígito lido em a2
        addi a2, a2, -'0'   # Transformando para inteiro
        mul a0, a0, t2      # Multiplica por 10 para corrigir o decimal montado
        add a0, a0, a2      # Soma o número inteiro lido em  a0 
        addi t0, t0, 1      # Incrementa o "i" para o próximo loop
        addi a1, a1, 1      # Para ir para o próximo dígito da iteração
        blt t0, a3, 1b     # Vai para a próxima iteração o loop se "i < 4"

    ret


square_root:
    li t0, 0    # "int i = 0" (para o loop)
    srli a2, a0, 1  # Chute inicial (o número divido por 2)
    li a3, 21      # Condição de parada do loop

    1:  
        div t1, a0, a2      # Divide o valor pelo chute anterior
        add t2, t1, a2      # Soma o chute anterior com a divisão passada
        srli a2, t2, 1      # Divide o resultado anterior por 2
        addi t0, t0, 1      # Incrementa o "i" para o próximo loop
        blt t0, a3, 1b      # Vai para a próxima iteração o loop se "i < 21"

    mv a0, a2       # Move o resultado obtido em a2 para a0 para o retorno

    ret


int_to_str:
    li t0, 4    # "int i = 4" (para o loop)
    li a3, 0    # Condição de parada do for
    li t2, 10   # Para que se possa fazer a conversão
    la a1, output   # Carrega o endereço de início da string de saída 
    add a1, a1, a2  # Coloca em a1 a posição do primeiro dígito que será gravado

    1:       
        rem t4, a0, t2      # Calcula o resto da divisão do número por 10
        div a0, a0, t2      # Divide o número que se tinha por 10 para a próxima iteração
        addi t4, t4, '0'    # Converte o número para um caractere
        sb t4, 0(a1)        # Carrega o dígito em questão na sua posição da saída
        addi t0, t0, -1     # Reduz o contador do loop
        addi a1, a1, -1     # Volta para o bit anterior (o que será sobrescrito na próxima iteração)
        bnez t0, 1b      # Vai para a próxima iteração do loop

    ret


format_str:
    /*
    * Usada para formatar a string da maneira correta
    * a5 -> Contém o valor correto de x
    * a0 -> Contém o valor de y
    */
    li t0, '+'
    li t1, '-'
    li t2, ' '
    li t3, '\n'
    li t4, 0        # Usado para saber se os valores são positivos ou negativos
    la a1, output   # Carrega o endereço do início da string de saída
    sb t2, 5(a1)    # Coloca um espaço entre os valores da saída
    sb t3, 11(a1)   # Coloca o \n no final da string de saída
    bge a5, t4, 1f  # Se x >= 0, coloca o '+' na primeira posição da saída
    sb t1, 0(a1)    # Se não, coloca o sinal de '-'
    j 2f

    1:
        sb t0, 0(a1)

    2:
        bge a0, t4, 3f  # Se y >= 0, coloca '+' na sexta posição da saída
        sb t1, 6(a1)    # Se não, coloca o sinal de '-'
        j end2

    3:
        sb t0, 6(a1)

    end2:
        ret


dist:
    /*
    * Usada para calcular a distância dos satélites até a pessoa
    */
    li t0, 3    # Velocidade da luz 
    li t1, 10   # Fator de correção (ordem de grandeza da velocidade e do tempo)
    neg a0, a0          # Inverte o sinal de a0
    add t3, s5, a0      # Calcula o delta t
    mul t4, t0, t3      # Calcula a distância com um erro na ordem de grandeza de 10
    div a0, t4, t1      # Ajusta a ordem de grandeza da distância

    ret   


calc_y:
    /*
    * Usada para encontrar a posição da pessoa em y
    */
    mul a1, s6, s6  # Pega o quadrado de da
    mul a2, s0, s0  # Pega o quadrado de Yb
    mul a3, s7, s7  # Pega o quadrado de db
    neg a3, a3      # Inverte o sinal de db quadrado
    add a0, a1, a2  # (da ** 2) + (Yb ** 2)
    add a0, a0, a3  # (da ** 2) + (Yb ** 2) - (db ** 2)
    slli t1, s0, 1  # Multiplica Tb por 2
    div a0, a0, t1  # ((da ** 2) + (Yb ** 2) - (db ** 2)) / 2Yb

    ret


calc_x:
    /*
    * Usada pra encontrar o módulo da pessoa em x
    */
    mul a1, s6, s6  # Pega o quadrado de da
    mul a2, s9, s9  # Pega o quadrado de y
    neg a2, a2      # Inverte o sinal de y quadrado
    add a0, a1, a2  # (da ** 2) - (y ** 2)

    ret


calc_best_x:
    /*
    * Substitui os valores de x na expressão para que o melhor possa ser encontrado
    * (x - XC) ** 2 + y ** 2= dC ** 2
    */
    mv a1, s1           # Carregará o valor negativo de Xc
    neg a1, a1          # Inverte o sinal de Xc
    mul a4, s8, s8      # dc ** 2
    neg a4, a4          # Inverte o sinal de dc quadrado
    mul a3, s9, s9      # y ** 2

    # Para x positivo
    add a2, s10, a1     # (x - Xc)
    mul a2, a2, a2      # (x - Xc) ** 2
    add a2, a2, a3      # ((x - Xc) ** 2) + (y ** 2)
    add a2, a2, a4      # ((x - Xc) ** 2) + (y ** 2) - (dc ** 2)

    # Para x negativo
    add a5, s11, a1     # (x - Xc)
    mul a5, a5, a5      # (x - Xc) ** 2
    add a5, a5, a3      # ((x - Xc) ** 2) + (y ** 2)
    add a5, a5, a4      # ((x - Xc) ** 2) + (y ** 2) - (dc ** 2)

    ret


decide_best_x:
    /*
    * Com base nos valores calculados anteriormente, decide qual dos dois é melhor
    * a2 -> valor calculado para x positivo (ao quadrado)
    * a5 -> valor calculado para x negativo (ao quadrado)
    */  
    li t0, 0            # Para que se possa verificar se o número é negativo
    bge a2, t0, 1f      # Se a2 >= 0, pula para o label 1
    neg a2, a2          # Caso contrário, inverte o sinal de a2

    1:
        bge a5, t0, 2f     # Se a5 >= 0, pula para o label 2
        neg a5, a5          # Caso contrário, inverte o sinal de a5

    2:
        blt a2, a5, 3f     # Se a2 < a5, o que estava em a2 é o valor de x correto
        mv a0, s11          # Coloco o valor correto de x em a0
        j end3               # Pula para o fim da rotina

    3:
        mv a0, s10      # Coloca em a0 o valor correto de x
        j end3          # Pula para o fim da rotina
    
    end3:
        ret


_start:
    /*
    s0 -> Yb (posição em y do satélite B)
    s1 -> Xc (posição em x do satélite C)
    s2 -> Ta (tempo em que o satélite A mandou o sinal)
    s3 -> Tb (tempo em que o satélite B mandou o sinal)
    s4 -> Tc (tempo em que o satélite C mandou o sinal)
    s5 -> Tr (tempo de recebimento dos sinais)
    s6 -> da (distância do satélite A até a pessoa)
    s7 -> db (distância do satélite B até a pessoa)
    s8 -> dc (distância do satélite C até a pessoa)
    s9 -> y (posição da pessoa em y)
    s10 -> x positivo (posição da pessoa em x)
    s11 -> x negativo (posição da pessoa em x)
    a5 -> valor de x correto para ser impresso
    */
    la a1, pos_input
    li a2, 12
    jal ra, read 

    la a1, time_imput
    li a2, 20
    jal ra, read    

    # Lendo Yb da entrada
    li a0, 0
    jal ra, str_to_int_sinal
    mv s0, a0

    # Lendo Xc da entrada
    li a0, 6
    jal ra, str_to_int_sinal
    mv s1, a0

    # Lendo Ta da entrada
    li a0, 0
    jal ra, str_to_int
    mv s2, a0

    # Lendo Tb da entrada
    li a0, 5
    jal ra, str_to_int
    mv s3, a0

    # Lendo Tc da entrada
    li a0, 10
    jal ra, str_to_int
    mv s4, a0

    # Lendo Tr da entrada
    li a0, 15
    jal ra, str_to_int
    mv s5, a0

    # Calculando da
    mv a0, s2
    jal ra, dist
    mv s6, a0

    # Calculando db
    mv a0, s3
    jal ra, dist
    mv s7, a0

    # Calculando dc
    mv a0, s4
    jal ra, dist
    mv s8, a0

    # Calculando y
    jal ra, calc_y
    mv s9, a0

    # Calculando o x
    jal ra, calc_x
    jal ra, square_root
    mv s10, a0      # Move para s10 0 valor de x considerando-o positivo
    neg a0, a0      # Inverte o sinal de x
    mv s11, a0      # Move para s11 o valor de x considerando-o negativo

    # Encontrando qual dois valores é o mais correto e imprimindo
    jal ra, calc_best_x
    jal ra, decide_best_x
    li a2, 4        # Primeiro dígito que será escrito na saída para x
    li t0, 0        # Para checar se o número é positivo ou negativo
    mv t1, a0       # Guarda o valor original de x correto em t1
    bge a0, t0, 1f
    neg a0, a0

    1:
        jal ra, int_to_str
        mv a0, t1       # Devolvo o valor de x para a0
        mv a5, a0       # Para salvar o valor do x correto
        mv a0, s9       # Para que o que está na rotina de int_to_str funcione corretamente
        mv t1, a0       # Para salvar o valor original de y em t1
        bge a0, t0, 2f
        neg a0, a0

    2:
        li a2, 10       # Primeiro dígito que será escrito na saída para y
        jal ra, int_to_str
        mv a0, t1       # Devolve o valor de y para a0

    jal ra, format_str      # Para formatar a saída do jeito correto
    jal ra, write

    # End (marca o fim da execução do programa)
    li a0, 0
    li a7, 93
    ecall
