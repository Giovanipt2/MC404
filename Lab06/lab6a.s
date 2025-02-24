.globl _start

.section .bss
string: .skip 20  # buffer


.section .text
read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, string # buffer to write the data
    li a2, 20  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret


write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, string       # buffer
    li a2, 20           # size
    li a7, 64           # syscall write (64)
    ecall
    ret


str_to_int:
    li t0, 0    # "int i = 0" (para o loop)
    la a1, string   # Carrega o endereço da entrada em a1
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
    li a3, 10   # Condição de parada do loop

    1:  
        div t1, a0, a2      # Divide o valor pelo chute anterior
        add t2, t1, a2      # Soma o chute anterior com a divisão passada
        srli a2, t2, 1      # Divide o resultado anterior por 2
        addi t0, t0, 1      # Incrementa o "i" para o próximo loop
        blt t0, a3, 1b      # Vai para a próxima iteração o loop se "i < 10"

    mv a0, a2       # Move o resultado obtido em a2 para a0 para o retorno

    ret


int_to_str:
    li t0, 4    # "int i = 4" (para o loop)
    li a3, 0    # Condição de parada do for
    li t2, 10   # Para que se possa fazer a conversão
    la a1, string   # Carrega o endereço de início da string
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


_start:
    jal ra, read    # Realiza a leitura da entrada
    
    # Transformará os números lidos em inteiros 
    li a0, 0        # Será usado como parâmetro para indicar a posição de início da leitura
    jal ra, str_to_int
    jal ra, square_root
    li a2, 3
    jal ra, int_to_str

    li a0, 5        # Será usado como parâmetro para indicar a posição de início da leitura
    jal ra, str_to_int
    jal ra, square_root
    li a2, 8
    jal ra, int_to_str

    li a0, 10       # Será usado como parâmetro para indicar a posição de início da leitura
    jal ra, str_to_int
    jal ra, square_root
    li a2, 13
    jal ra, int_to_str

    li a0, 15       # Será usado como parâmetro para indicar a posição de início da leitura
    jal ra, str_to_int
    jal ra, square_root
    li a2, 18
    jal ra, int_to_str

    jal ra, write

    li a0, 0
    li a7, 93
    ecall
