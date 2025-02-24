.globl _start

.data
input_file: .asciz "image.pgm"  # Nome do arquivo de imagem

.bss
buffer: .skip 262159            # Buffer para armazenar o conteúdo da imagem 

.text
open:
    la a0, input_file      # Endereço do nome do arquivo
    li a1, 0               # Flags (0: read only)
    li a2, 0               # Mode (não utilizado aqui)
    li a7, 1024            # Syscall: open
    ecall

read:
    la a1, buffer          # Endereço do buffer
    li a2, 262159          # Número de bytes para ler
    li a7, 63              # Syscall: read
    ecall

close: 
    mv a0, s0              # Passa o file descriptor
    li a7, 57              # Syscall: close
    ecall

read_header:
    /*
    * Função para a leitura do cabeçalho do arquivo PGM
    */
    # Pular a primeira linha (P5)
    addi a1, a1, 3         # Pula o "P5\n"
        
    # Ler a largura da imagem
    li t0, 0               # Inicializa a largura em t0

    read_width:
        li t4, ' '
        li t5, 10
        lb t1, 0(a1)                # Lê um byte do buffer
        beq t1, t4, read_height     # Se encontrar um espaço, terminou a largura
        addi t1, t1, -'0'           # Converte o caractere para número
        mul t0, t0, t5              # Multiplica por 10 para formar o número
        add t0, t0, t1              # Adiciona o novo dígito
        addi a1, a1, 1              # Move para o próximo caractere
        j read_width
        
    read_height:
        mv s1, t0              # Salva em s1 a largura encontrada
        addi a1, a1, 1         # Pula o espaço
        li t0, 0               # Inicializa a altura em t0

    1:
        li t3, '\n'                 # Procura pela quebra de linha (final da leitura das dimensões da imagem)
        lb t1, 0(a1)                # Lê um byte do buffer
        beq t1, t3, read_maxval     # Se encontrar nova linha, terminou a altura
        addi t1, t1, -'0'           # Converte o caractere para número
        mul t0, t0, t5              # Multiplica por 10 para formar o número
        add t0, t0, t1              # Adiciona o novo dígito
        addi a1, a1, 1              # Move para o próximo caractere
        j 1b

    read_maxval:
        addi a1, a1, 4         # Pular o "255\n" (valor máximo é sempre 255)
        mv s2, t0              # Salva a altura em s2
        ret

draw_image:
    # Desenhar a imagem no Canvas
    mv t0, s3       # Ponteiro para o buffer de imagem
    li t1, 0        # Inicializa a coordenada Y

    draw_loop_y:
        li t2, 0                       # Inicializa a coordenada X

    draw_loop_x:
        lb t3, 0(t0)                   # Carrega o byte do buffer (nível de cinza)
        li t4, 0xFF

        # Para colocar os bits de cada cor na posição certa          
        slli t3, t3, 8                 # Move o valor para a parte azul
        or t4, t3, t4                  # Aplica o valor de cinza ao canal azul
        slli t3, t3, 16                # Move o valor para a parte verde
        or t4, t3, t4                  # Aplica o valor de cinza ao canal verde
        slli t3, t3, 24                # Move o valor para a parte vermelha
        or t4, t3, t4                  # Aplica o valor de cinza ao canal vermelho

        mv a0, t2                      # Coordenada X
        mv a1, t1                      # Coordenada Y
        mv a2, t4                      # Cor (R=G=B=nível de cinza, A=255)
        li a7, 2200                    # Syscall setPixel
        ecall

        addi t0, t0, 1                 # Avança para o próximo byte
        addi t2, t2, 1                 # Incrementa a coordenada X
        blt t2, s1, draw_loop_x        # Se X < largura, continue desenhando

        addi t1, t1, 1                 # Incrementa a coordenada Y
        blt t1, s2, draw_loop_y        # Se Y < altura, continue desenhando

_start:
    /*
    * s0 -> file descriptor
    * s1 -> largura da imagem
    * s2 -> altura da imagem
    */
    # Abre o arquivo para poder ser lido
    jal ra, open
    mv s0, a0              

    # Ler o arquivo de imagem
    jal ra, read

    # Ler o cabeçalho da imagem PGM
    la a1, buffer           # Carrega o buffer que contém a imagem
    jal ra, read_header     # Interpretar o cabeçalho PGM (largura, altura)
    mv s3, a1               # Salva em s3 o local de início da imagem, pulando o cabeçalho lido

    # Ajustar o tamanho do Canvas
    mv a0, s1              # Largura da imagem
    mv a1, s2              # Altura da imagem
    li a7, 2201            # Syscall: setCanvasSize
    ecall

    # Desenhar a imagem pixel a pixel no Canvas
    jal ra, draw_image     # Função que desenha a imagem

    # Fecha o arquivo após sua leitura
    jal ra, close

    # End (marca o fim da execução do programa)
    li a0, 0
    li a7, 93
    ecall
