.globl _start

.set BASE_ADDR, 0xFFFF0100                  # Usado para começar a ler as coordenadas do GPS (base)
.set X_COORD_ADDR, 0xFFFF0100 + 0x10        # Usado para ler a coordenada X do GPS
.set STEER_WHEELS_ADDR, 0xFFFF0100 + 0x20   # Usado para girar as rodas do caro
.set ENGINE_DIR_ADDR, 0xFFFF0100 + 0x21     # Usado para indicar a direção do motor
.set BRAKES_ADDR, 0xFFFF0100 + 0x22         # Usado para acionar os freios


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


_start:
    li t0, 1        # Valor de acionamento das funções do carro
    li t1, 135      # Valor que deve estar no byte de X_COORD_ADDR para parar e virar o carro
    li t2, -17      # Valor que indica o quanto o carro deve virar (negativo para ser para a esquerda)

    # Faz com que o carro se mova para frente e vá virando
    li a0, ENGINE_DIR_ADDR
    sb t0, 0(a0)        
    li a0, STEER_WHEELS_ADDR
    sb t2, 0(a0)
    
    1:
        li a0, BASE_ADDR
        sb t0, 0(a0)    # Inicializa o GPS
        lb t3, 0(a0)    # Lê o byte do GPS (para saber se atualizou)
        bnez t3, 1b     # Se o byte do GPS não for 0, continua no loop

    # Lê as coordenadas do GPS
    li a0, X_COORD_ADDR
    lw a1, 0(a0)    # Lê a coordenada X do GPS
    
    # Verifica se o carro chegou na posição desejada
    bgt a1, t1, 1b

    li a0 , ENGINE_DIR_ADDR
    sb zero, 0(a0)  # Para o carro
    li a0, BRAKES_ADDR
    sb t0, 0(a0)    # Para o carro

    # Encerra a execução do programa
    li a0, 0
    jal ra, exit
