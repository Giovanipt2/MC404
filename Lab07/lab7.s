.globl _start

.section .bss
input_1: .skip 5    # Número que será codificado
input_2: .skip 8    # Número que será decodificado
output_1: .skip 8   # Saída para o número que foi codificado
output_2: .skip 5   # Saída para o número que foi decodificado
output_3: .skip 2   # Saída se houve erro na decodificação ou não


.section .text
read:
    li a0, 0  # file descriptor = 0 (stdin)
    li a7, 63 # syscall read (63)
    ecall
    ret


write:
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall
    ret


str_to_bit:
    /*
    * Forma de extrair os bits d1, d2, d3 e d4 da entrada aque será codificada
    */
    la a1, input_1

    # Extração do primeiro dígito (d1)
    lb s3, 0(a1) 
    addi s3, s3, -'0'

    # Extração do segundo dígito (d2)
    lb s4, 1(a1)
    addi s4, s4, -'0'

    # Extração do terceiro dígito (d3)
    lb s5, 2(a1)
    addi s5, s5, -'0'

    # Extração do quarto dígito (d4)
    lb s6, 3(a1)
    addi s6, s6, -'0'

    ret


str_to_bit_cod:
    /*
    * Extrai os bits da mensagem decodificada 
    */
    la a1, input_2

    # Extraindo o p1
    lb s0, 0(a1)    
    addi s0, s0, -'0'

    # Extraindo o p2
    lb s1, 1(a1)
    addi s1, s1, -'0'

    # Extraindo o d1
    lb s3, 2(a1)
    addi s3, s3, -'0'

    # Extraindo o p3
    lb s2, 3(a1)
    addi s2, s2, -'0'

    # Extraindo o d2
    lb s4, 4(a1)
    addi s4, s4, -'0'

    # Extraindo o d3
    lb s5, 5(a1)
    addi s5, s5, -'0'

    # Extraindo o d4
    lb s6, 6(a1)
    addi s6, s6, -'0'

    ret


hamming_code:
    /*
    * Encontra os bits de paridade para montar a mensagem codificada
    */
    # Encontrando o primeiro bit de paridade (p1)
    xor s0, s3, s4
    xor s0, s0, s6

    # Encontrando o segundo bit de paridade (p2)
    xor s1, s3, s5
    xor s1, s1, s6

    # Encontrando o terceiro bit de paridade (p3)
    xor s2, s4, s5
    xor s2, s2, s6

    ret


str_codificada:
    /*
    * Formará a saída para o número que foi codificado
    */
    li t0, '\n'
    la a1, output_1
    sb t0, 7(a1)    # Coloca o '\n' no final da string

    # Transformando os bits em caracteres para a impressão
    addi s0, s0, '0'  
    addi s1, s1, '0'   
    addi s2, s2, '0'   
    addi s3, s3, '0'   
    addi s4, s4, '0'   
    addi s5, s5, '0'   
    addi s6, s6, '0'  

    sb s0, 0(a1) 
    sb s1, 1(a1)
    sb s3, 2(a1)
    sb s2, 3(a1)
    sb s4, 4(a1)
    sb s5, 5(a1)
    sb s6, 6(a1)

    ret


str_decodificada:
    /*
    * Formará a saída para o número decodificado
    */
    li t0, '\n'
    la a1, output_2
    sb t0, 4(a1)    # Coloca o '\n' no final da string

    # Transformando os bits em caracteres para a impressão
    addi s3, s3, '0'
    addi s4, s4, '0'
    addi s5, s5, '0'
    addi s6, s6, '0'

    sb s3, 0(a1)
    sb s4, 1(a1)
    sb s5, 2(a1)
    sb s6, 3(a1)

    ret


find_error:
    /*
    * Encontra se existe ou não um erro na codificação
    */
    li t0, '\n'
    la a1, output_3
    sb t0, 1(a1)    # Para colocar o '\n' no final da string

    # Encontrando o primeiro bit de paridade (p1)
    xor t0, s3, s4
    xor t0, t0, s6

    # Encontrando o segundo bit de paridade (p2)
    xor t1, s3, s5
    xor t1, t1, s6

    # Encontrando o terceiro bit de paridade (p3)
    xor t2, s4, s5
    xor t2, t2, s6
    
    # Verifica se o p1 dado e o calculado são iguais
    xor a0, t0, s0
    bnez a0, erro

    # Verifica se o p2 dado e o calculado são iguais
    xor a0, t1, s1
    bnez a0, erro

    # Verifica se o p3 dado e o calculado são iguais
    xor a0, t2, s2
    bnez a0, erro

    # Se não houve nenhum erro, grava 0 na saída e vai para o fim da rotina
    addi a0, a0, '0'
    sb a0, 0(a1)
    j end

    erro:
        addi a0, a0, '0'
        sb a0, 0(a1)

    end:
        ret


_start:
    /*
    * s0 -> p1 (primeiro bit de paridade)
    * s1 -> p2 (segundo bit de paridade)
    * s2 -> p3 (terceiro bit de paridade)
    * s3 -> d1 (primeiro bit)
    * s4 -> d2 (segundo bit)
    * s5 -> d3 (terceiro bit)
    * s6 -> d4 (quarto bit)
    */
    # Lendo o número que será codificado
    la a1, input_1
    li a2, 5
    jal ra, read

    # Lendo o número que será decodificado
    la a1, input_2
    li a2, 8
    jal ra, read

    # Encontrando o número codificado
    jal ra, str_to_bit
    jal ra, hamming_code
    jal ra, str_codificada
    la a1, output_1
    li a2, 8
    jal ra, write

    # Encontrando o número decodificado
    jal ra, str_to_bit_cod
    jal ra, find_error
    jal ra, str_decodificada
    la a1, output_2
    li a2, 5
    jal ra, write
    la a1, output_3
    li a2, 2
    jal ra, write

    # End (marca o fim da execução do programa)
    li a0, 0
    li a7, 93
    ecall
