.globl _start

.data
input_file: .string "image.pgm"  # Nome do arquivo de imagem

.bss
buffer: .skip 262159            # Buffer para armazenar o conteúdo da imagem 
filtered_image: .skip 262159    # Imagem de saída após a aplicação do filtro


.text
open:
    la a0, input_file      # Endereço do nome do arquivo
    li a1, 0               # Flags (0: read only)
    li a2, 0               # Mode (não utilizado aqui)
    li a7, 1024            # Syscall: open
    ecall

    ret


read:
    la a1, buffer          # Endereço do buffer
    li a2, 262159          # Número de bytes para ler
    li a7, 63              # Syscall: read
    ecall

    ret


close: 
    mv a0, s0              # Passa o file descriptor
    li a7, 57              # Syscall: close
    ecall

    ret


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
        addi a1, a1, 5         # Pular o "255\n" (valor máximo é sempre 255)
        mv s2, t0              # Salva a altura em s2
    
    ret


apply_filter:
    /*
    * Aplica o filtro na imagem dada
    * a0 -> início da imagem dada (depois do cabeçalho)
    * a1 -> início da imagem de saída
    * a2 -> índice da última posição válida em uma linha
    * a3 -> íncide da última posição válida em uma coluna
    * t0 -> coordenada y
    * t1 -> coordenada x
    * t4 -> cor preta (0)
    * t5 -> cor branca (255)
    * a4 -> byte lido da imagem dada
    * t2 -> valor 8
    * t6 -> valores auxiliares lidos para fazer a máscara
    */
    mv a0, s3       # Início da imagem dada de entrada
    la a1, filtered_image       # Ponteiro para o início da imagem de saída
    li t4, 0        # Cor preta
    li t5, 255      # Cor branca
    li t2, 8        # Para aplicar o filtro

    # Coloca os limites das bordas da imagem, para saber quando pintar de preto
    mv a2, s1       
    addi a2, a2, -1     # Última posição lateral do arquivo
    mv a3, s2
    addi a3, a3, -1     # Última posição vertical do arquivo

    li t0, 0        # Inicializa a coordenada Y

    loop_y:
        li t1, 0    # Inicializa a coordenada X
        beqz t0, set_black_line         # Se a coordenada Y for 0
        beq t0, a3, set_black_line      # Se Y atingiu a borda final

        loop_x:
            beqz t1, set_black      # Se a coordenada X for 0
            beq t1, a2, set_black   # Se X atingiu a borda final

            lbu a4, 0(a0)           # Carrega o byte da imagem dada na entrada
            mul a4, a4, t2          # Multiplica o valor do byte por 8
            mv a5, a0               # Move para a5 a posição em que estamos no arquivo (para não estragar a0)
            
            # Pegando a posição m[i - 1][j - 1]
            sub a5, a5, s1      # Volta uma linha
            addi a5, a5, -1     # Volta uma posição na linha
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i - 1][j]
            addi a5, a5, 1      # Avança uma posição na linha
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i - 1][j + 1]
            addi a5, a5, 1
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i][j - 1]
            add a5, a5, s1      # Desce uma linha
            addi a5, a5, -2     # Volta duas posições na linha
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i][j + 1]
            addi a5, a5, 2      # Pula o pixel em que estávamos e pega o próximo
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i + 1][j - 1]
            add a5, a5, s1      # Desce uma linha
            addi a5, a5, -2     # Volta duas posições na linha
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i + 1][j]
            addi a5, a5, 1
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Pegando a posição m[i + 1][j + 1]
            addi a5, a5, 1
            lbu t6, 0(a5)       # Carrega o valor desse byte em t6
            sub a4, a4, t6      # Subtrai o que estava nesse byte do byte em questão

            # Verifica se o valor de a4 está entre 0 e 255
            bgt a4, t5, set_255     # Se o valor de a4 é maior que 255
            blt a4, t4, set_0       # Se o valor de a4 é menor que 0
            j 3f

            set_255:
            li a4, 255
            j 3f

            set_0:
            li a4, 0
            j 3f

            3:
            sb a4, 0(a1)    # Coloca o valor desse byte na imagem de saída
            addi t1, t1, 1  # Adiciona 1 na coordenada x
            addi a0, a0, 1  # Vai para o próximo byte a ser lido da imagem de entrada
            addi a1, a1, 1  # Vai para a próxima posição da imagem de saída
            j loop_x


        # Pinta um pixel da borda lateral de preto
        set_black:
            sb t4, 0(a1)
            addi a1, a1, 1          # Vai para o próximo pixel da imagem de saída
            addi a0, a0, 1          # A imagem dada na entrada "anda" junto com a de saída
            beq t1, a2, 1f          # Se era o último pixel da linha
            j 2f

            1:
            addi t0, t0, 1  # Incrementa 1 na coordenada y
            j loop_y        

            2:
            addi t1, t1, 1          # Se não era, incrementa 1 na coordenada x
            j loop_x

    # Pinta toda a linha de preto
    set_black_line:
        1:
            sb t4, 0(a1)
            addi t1, t1, 1      # Anda 1 na coordenada x
            addi a1, a1, 1      # Vai para o próximo pixel da imagem dada
            addi a0, a0, 1      # A imagem dada na entrada "anda" junto com a de saída
            blt t1, s1, 1b
        
        beq t0, a3, end     # Se era a última linha, vai para o final
        addi t0, t0, 1      # Incrementa 1 na coordenada do y
        j loop_y

    end:
        ret


draw_filtered_image:
    # Desenhar a imagem no Canvas
    la t0, filtered_image       # Ponteiro para o buffer de imagem
    li t1, 0            # Inicializa a coordenada Y

    draw_loop_y:
        li t2, 0                       # Inicializa a coordenada X

    draw_loop_x:
        lbu t3, 0(t0)                  # Carrega o byte do buffer (nível de cinza)

        # Para colocar os bits de cada cor na posição certa
        mv a2, t3
        slli a2, a2, 8
        or a2, a2, t3
        slli a2, a2, 8
        or a2, a2, t3
        slli a2, a2, 8       
        ori a2, a2, 0xFF

        mv a0, t2                      # Coordenada X
        mv a1, t1                      # Coordenada Y
        li a7, 2200                    # Syscall setPixel
        ecall

        addi t0, t0, 1                 # Avança para o próximo byte
        addi t2, t2, 1                 # Incrementa a coordenada X
        blt t2, s1, draw_loop_x        # Se X < largura, continue desenhando

        addi t1, t1, 1                 # Incrementa a coordenada Y
        blt t1, s2, draw_loop_y        # Se Y < altura, continue desenhando

    ret


_start:
    /*
    * s0 -> file descriptor
    * s1 -> largura da imagem
    * s2 -> altura da imagem
    * s3 -> início da imagem (pulando o cabeçalho)
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

    # Aplica o filtro na imagem
    jal ra, apply_filter

    # Desenhar a imagem pixel a pixel no Canvas
    jal ra, draw_filtered_image     # Função que desenha a imagem
    # li a0, 10
    # li a1, 10
    # li a7, 2202
    # ecall

    # Fecha o arquivo após sua leitura
    jal ra, close

    # End (marca o fim da execução do programa)
    li a0, 0
    li a7, 93
    ecall
