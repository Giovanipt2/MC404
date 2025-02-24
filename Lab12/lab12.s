.globl _start

.set WRITE_TRIGGER, 0xFFFF0100          # Usado para acionar a escrita de um byte
.set BYTE_WRITEN, 0xFFFF0100 + 0x01     # O byte dessa posição é escrito quando WRITE_TRIGGER é 1
.set READ_TRIGGER, 0xFFFF0100 + 0x02    # Usado para acionar a leitura de um byte
.set BYTE_READ, 0xFFFF0100 + 0x03       # O byte dessa posição é lido quando READ_TRIGGER é 1

.section .bss
operation: .skip 2
input: .skip 128
temp_buffer: .skip 32

.section .text
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


read:
    /**
    * Lê uma string de tamanho variável até o caractere '\n'
    * Salva os caracteres lidos na string de entrada
    * 
    * Parâmetros:
    * a0 = ponteiro para a string de entrada
    */
    mv a1, a0       # Guarda o endereço da string de entrada em a1
    li t0, 1        # Valor de acionamento das funções de leitura e escrita
    li t1, '\n'     # Para saber quando parar de ler
    
    1:
        li a0, READ_TRIGGER
        sb t0, 0(a0)    # Aciona a leitura

    # Verifica se o byte em READ_TRIGGER já virou 0 (terminou a leitura)
    2:
        lb t2, 0(a0)
        bnez t2, 2b

        # Lê os caracteres até encontrar '\n'
        li a0, BYTE_READ    # Endereço do byte lido
        lb t3, 0(a0)        # Lê o caractere
        sb t3, 0(a1)        # Coloca o caractere lido na string de entrada
        addi a1, a1, 1      # Vai para o próximo caractere
        bne t3, t1, 1b      # Se não for '\n', volta para ler o próximo caractere

    ret


write:
    /**
    * Escreve uma string de tamanho variável até o caractere '\n'
    *
    * Parâmetros:
    * a0 = ponteiro para a string de saída
    */
    mv a1, a0       # Guarda o endereço da string de saída em a1
    li t0, 1        # Valor de acionamento das funções de leitura e escrita
    li t1, '\n'     # Para saber quando parar de escrever

    1:
        li a0, BYTE_WRITEN
        lb t2, 0(a1)    # Lê o caractere
        sb t2, 0(a0)    # Coloca o caractere na saída
        addi a1, a1, 1  # Vai para o próximo caractere
        li a0, WRITE_TRIGGER
        sb t0, 0(a0)    # Aciona a escrita

    # Verifica se o byte em WRITE_TRIGGER já virou 0 (terminou a escrita)
    2:
        lb t3, 0(a0)
        bnez t3, 2b         # Se WRITE_TRIGGER ainda for 1, ainda não escreveu
        bne t2, t1, 1b      # Se não for '\n', volta para escrever o próximo caractere
    
    ret


reverse_str:
    /**
    * Inverte uma string
    *
    * Parâmetros:
    * a0 = ponteiro para a string de entrada
    * a1 = ponteiro para o final da string
    */
    1:
        lb t0, 0(a1)        # Carrega o caractere da última posição
        lb t1, 0(a0)        # Carrega o caractere da primeira posição
        sb t1, 0(a1)        # Troca o caractere da posição atual
        sb t0, 0(a0)        # Troca o caractere da posição oposta
        addi a1, a1, -1     # Vai para o próximo caractere
        addi a0, a0, 1      # Vai para o próximo caractere
        blt a0, a1, 1b      # Se ainda não terminou, volte para a próxima iteração


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
    li t1, '\n' # Usado para saber quando parar de ler
    li t2, 10   # Carrega o imediato 10 em t2
    mv a1, a0   # Guarda o endereço da string de entrada em a1
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
        lb a2, 0(a1)        # Guarda o dígito lido em a2
        beq a2, t1, 2f      # Se for '\n', pule para o final
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
    * Se a base for 10, coloca um sinal negativo na string se o número for negativo
    * Se a base for 16, considerará como sendo um valor unsigned e não colocará "0x" no início
    *
    * Parâmetros:
    * a0 = número inteiro a ser convertido
    * a1 = ponteiro para a string de saída
    * a2 = base numérica usada na conversão
    *
    * Retorno:
    * Endereço para a string de saída
    * A string de saída é terminada em '\n'
    */  
    li t1, '-'      # Para identificar o sinal negativo
    li t2, '\n'     # Para sinalizar o final da string
    li t3, 10       # Base 10

    # Verifica qual é a base em questão
    bne a2, t3, unsigned_conversion     # Se a base não for 10, converte como unsigned

    # Verifica se o número é negativo
    bltz a0, negative2          # Se for negativo, vá para negativo
    j unsigned_conversion       # Se não for negativo, vá para a conversão dos dígitos

    negative2:
        sb t1, 0(a1)    # Coloca o sinal negativo na string
        addi a1, a1, 1  # Pula o caractere '-'
        neg a0, a0      # Inverte o sinal do número

    unsigned_conversion:
        mv a3, a1       # Guarda o endereço de início da string de saída em a3

        # Converte o número para string
        1:
            remu t4, a0, a2              # Calcula o resto da divisão do número pela base
            divu a0, a0, a2              # Divide o número que se tinha pela base para a próxima iteração
            blt t4, t3, store_digit     # Se o dígito for menor que 10, ele pode ser colocado na string diretamente
            addi t4, t4, 'A'            # Se o dígito for maior que 9, ele deve ser convertido para a letra correspondente
            addi t4, t4, -10 - '0'      # Ajusta o valor para a letra correspondente
            
            store_digit:
                addi t4, t4, '0'    # Converte o número para um caractere
                sb t4, 0(a1)        # Carrega o dígito em questão na sua posição da saída
                addi a1, a1, 1      # Vai para o próximo caractere
                bnez a0, 1b         # Vai para a próxima iteração do loop

        sb t2, 0(a1)            # Coloca o caractere '\n' no final da string
        
        # Inverte a string
        addi a1, a1, -1         # Volta para o último caractere
        beq a3, a1, end2        # Se só há um dígito, não é necessário inverter

        2:
            lb t4, 0(a1)        # Carrega o caractere da última posição
            lb t5, 0(a3)        # Carrega o caractere da primeira posição
            sb t5, 0(a1)        # Troca o caractere da posição atual
            sb t4, 0(a3)        # Troca o caractere da posição oposta
            addi a1, a1, -1     # Vai para o próximo caractere
            addi a3, a3, 1      # Vai para o próximo caractere
            blt a3, a1, 2b      # Se ainda não terminou, volte para a próxima iteração

    end2:
        mv a0, a5    # Retorna o endereço da string de saída em a0
        ret


calc_expression:
    /**
    * Encontra qual é a expressão algébrica e calcula o seu resultado
    * Lê até o primeiro espaço para encontrar o primeiro número
    * Pula esse espaço para ler o operador
    * Pula o espaço após o operador para ler o segundo número e  vai até o '\n'
    * Os caracteres dos números lidos vão sendo armazenados em um buffer temporário
    * a3 = endereço da string de entrada (para poder usar a0 como parâmetro da atoi)
    * a4 = primeiro número lido
    * a5 = símbolo da operação que se deseja realizar
    * a6 = segundo número lido
    *
    * Parâmetros:
    * a0 = ponteiro para a string de entrada
    *
    * Retorno:
    * a0 = resultado da expressão
    */
    la a1, temp_buffer  # Guarda o endereço do buffer temporário em a1
    mv a3, a0           # Guarda o endereço da string de entrada em a3
    addi sp, sp, -4     # Reserva espaço na pilha
    sw ra, 0(sp)        # Salva o endereço de retorno na pilha

    # Símbolos necessários para descobrir corretamente a expressão
    li s6, ' '      # Para identificar o espaço
    li s7, '\n'     # Para identificar o final da string
    li s8, '+'      # Para identificar a soma
    li s9, '-'      # Para identificar a subtração
    li s10, '*'     # Para identificar a multiplicação
    li s11, '/'     # Para identificar a divisão

    # Lê o primeiro número
    1:
        lb t6, 0(a3)    # Lê o caractere
        beq t6, s6, 2f  # Se for um espaço, vai para a conversão para número
        sb t6, 0(a1)    # Coloca o caractere no buffer temporário
        addi a3, a3, 1  # Vai para o próximo caractere a ser lido
        addi a1, a1, 1  # Vai para o próximo caractere (que será escrito)
        j 1b            # Se não for um espaço, continua lendo o número

    2:
        sb s7, 0(a1)    # Coloca o caractere '\n' no final do buffer temporário
        la a0, temp_buffer
        jal atoi        # Converte o número para inteiro
        mv a4, a0       # Guarda o número lido em a4

    # Lê o operador
    addi a3, a3, 1      # Pula o espaço
    lb a5, 0(a3)        # Lê o operador
    addi a3, a3, 2      # Pula o operador e o espaço depois dele

    # Lê o segundo número
    la a1, temp_buffer  # Volta para o início do buffer temporário
    3:
        lb t6, 0(a3)    # Lê o caractere
        beq t6, s7, 4f  # Se for '\n', vai para a conversão para número
        sb t6, 0(a1)    # Coloca o caractere no buffer temporário
        addi a3, a3, 1  # Vai para o próximo caractere a ser lido
        addi a1, a1, 1  # Vai para o próximo caractere (que será escrito)
        j 3b            # Se não for '\n', continua lendo o número

    4:
        sb s7, 0(a1)    # Coloca o caractere '\n' no final do buffer temporário
        la a0, temp_buffer
        jal atoi        # Converte o número para inteiro
        mv a6, a0       # Guarda o número lido em a6

    # Descobre qual é a operação que se deseja realizar
    beq a5, s8, sum
    beq a5, s9, subt
    beq a5, s10, mult
    beq a5, s11, divi

    sum:
        add a0, a4, a6
        j end_calc

    subt:
        sub a0, a4, a6
        j end_calc

    mult:
        mul a0, a4, a6
        j end_calc

    divi:
        div a0, a4, a6
        j end_calc

    end_calc:
        lw ra, 0(sp)    # Restaura o endereço de retorno
        addi sp, sp, 4  # Libera o espaço na pilha
        ret


_start:
    /**
    * s0 = número da operação lida
    *
    * Operações:
    * 1 = lê uma string de tamanho variável e a escreve de volta
    * 2 = lê uma string de tamanho variável e a escreve de volta invertida
    * 3 = lê uma string de tamanho variável que representa um número decimal e a escreve em sua representação hexadecimal
    * 4 = lê uma string de tamanho variável que representa uma expressão algébrica e a escreve seu resultado
    *
    * s1  = 1 (representando a primeira operação)
    * s2  = 2 (representando a segunda operação)
    * s3  = 3 (representando a terceira operação)
    * s4  = 4 (representando a quarta operação)
    * s5 = ponteiro para a última posição da string de entrada
    */  
    li s1, 1
    li s2, 2
    li s3, 3
    li s4, 4

    # Lê a operação desejada
    la a0, operation
    jal read
    la a0, operation
    jal atoi    # Converte para inteiro
    mv s0, a0       # Guarda o número da operação em s0

    # Lê a string de entrada
    la a0, input
    jal read
    addi a1, a1, -2     # Volta para o último caractere
    mv s5, a1           # Guarda o endereço da última posição da string de entrada em s5

    # Verifica qual operação deve ser realizada
    beq s0, s1, operation1
    beq s0, s2, operation2
    beq s0, s3, operation3
    beq s0, s4, operation4

    # Escreve a string de entrada
    operation1:
        la a0, input
        jal write
        j end

    # Inverte a string de entrada
    operation2:
        la a0, input
        mv a1, s5
        jal reverse_str
        la a0, input
        jal write
        j end

    # Converte a string de entrada para hexadecimal
    operation3:
        la a0, input
        jal atoi
        la a1, temp_buffer
        li a2, 16
        jal itoa
        la a0, temp_buffer
        jal write
        j end

    # Calcula o resultado da expressão algébrica
    operation4:
        la a0, input
        jal calc_expression
        la a1, temp_buffer
        li a2, 10
        jal itoa
        la a0, temp_buffer
        jal write
        j end

    # Encerra a execução do programa
    end:
        li a0, 0
        jal ra, exit
