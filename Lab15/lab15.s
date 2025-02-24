.globl _start
.globl control_logic

.set BASE_ADDR, 0xFFFF0100                  # Usado para começar a ler as coordenadas do GPS (base)
.set X_COORD_ADDR, 0xFFFF0100 + 0x10        # Usado para ler a coordenada X do GPS
.set STEER_WHEELS_ADDR, 0xFFFF0100 + 0x20   # Usado para girar as rodas do caro
.set ENGINE_DIR_ADDR, 0xFFFF0100 + 0x21     # Usado para indicar a direção do motor
.set BRAKES_ADDR, 0xFFFF0100 + 0x22         # Usado para acionar os freios

.section .bss
.align 4
x_position: .skip 4
y_position: .skip 4
z_position: .skip 4
program_stack: .skip 1024
program_stack_end:
isr_stack: .skip 16
isr_stack_end:

.section .text
.align 2
int_handler:
    /**
    * Syscall and Interrupts handler
    *
    * Parametros:
    * a0 = primeiro parâmetro
    * a1 = segundo parâmetro (se houver)
    * a2 = terceiro parâmetro (se houver)
    * a7 = código da syscall
    *   10 = syscall_set_engine_and_steering
    *   11 = syscall_set_hand_brake
    *   15 = syscall_get_position
    *
    * Retorno:
    * Se a syscall for a de ligar o motor, retorna 0 se deu certo e 1 se recebeu parâmetros inválidos
    */
    # Salva o contexto
    csrrw sp, mscratch, sp  # Salva o ponteiro da pilha
    addi sp, sp, -32        # Aloca espaço para o contexto
    sw t0, 0(sp)            # Salva os registradores
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw a7, 28(sp)

    # Possíveis códigos de syscall
    li t0, 10
    li t1, 11
    li t2, 15

    # Verifica qual foi a syscall chamada (pelo código em a7)
    beq a7, t0, set_engine_and_steering
    beq a7, t1, set_hand_brake
    beq a7, t2, get_position

    set_engine_and_steering:
        # Verifica se os parâmetros são válidos
        li t0, 1
        li t1, -1
        li t2, 127
        li t3, -127
        bgt a0, t0, invalid_params
        blt a0, t1, invalid_params
        bgt a1, t2, invalid_params
        blt a1, t3, invalid_params

        # Ativa o motor
        li t0, ENGINE_DIR_ADDR
        sb a0, 0(t0)

        # Gira as rodas
        li t0, STEER_WHEELS_ADDR
        sb a1, 0(t0)

        li a0, 0
        j end
    
    invalid_params:
        li a0, 1
        j end

    set_hand_brake:
        # Aciona os freios
        li t0, BRAKES_ADDR
        sb a0, 0(t0)
        j end

    get_position:
        # Lê as coordenadas do GPS
        li t1, 1
        li t0, BASE_ADDR
        sb t1, 0(t0)            # Inicializa o GPS
        lb t3, 0(t0)            # Lê o byte do GPS (para saber se atualizou)
        bnez t3, get_position   # Se o byte do GPS não for 0, continua no loop

        li t0, X_COORD_ADDR
        lw a0, 0(t0)
        j end

    end:
        # Restaura o contexto
        lw t0, 0(sp)            # Salva os registradores
        lw t1, 4(sp)
        lw t2, 8(sp)
        lw t3, 12(sp)
        lw a0, 16(sp)
        lw a1, 20(sp)
        lw a2, 24(sp)
        lw a7, 28(sp)
        addi sp, sp, 32         # Desaloca espaço da pilha
        csrrw sp, mscratch, sp  # Restaura o ponteiro da pilha

        csrr t0, mepc     # load return address (address of the instruction that invoked the syscall)
        addi t0, t0, 4    # adds 4 to the return address (to return after ecall)
        csrw mepc, t0     # stores the return address back on mepc

        mret              # Recover remaining context (pc <- mepc)


.align 2
control_logic:
    /**
    * Implementa a lógica de controle do carro
    */
    li a3, 135      # Valor que deve estar no byte de X_COORD_ADDR para parar e virar o carro
    li a0, 1        # Valor de acionamento das funções do carro
    li a1, -16      # Valor que indica o quanto o carro deve virar (negativo para ser para a esquerda)
    
    # Faz com que o carro se mova para frente e vá virando
    li a7, 10
    ecall

    1:
        # Lê as coordenadas do GPS para saber quando parar
        la a0, x_position
        la a1, y_position
        la a2, z_position
        li a7, 15
        ecall
    
    # Verifica se o carro chegou na posição desejada
    bgt a0, a3, 1b

    # Caso tenha chegado, para o carro
    # Desliga o motor
    li a0, 0
    li a1, 0
    li a7, 10
    ecall

    # Aciona os freios
    li a0, 1
    li a7, 11
    ecall


.align 2
_start:
    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set the interrupt array.

    la sp, program_stack_end    # Set the stack pointer to the top of the program stack
    la t0, isr_stack_end        # Save the stack pointer in the mscratch register
    csrw mscratch, t0

    csrr t1, mstatus  # Update the mstatus.MPP
    li t2, ~0x1800    # field (bits 11 and 12)
    and t1, t1, t2    # with value 00 (U-mode)
    csrw mstatus, t1

    la t0, user_main  # Loads the user software
    csrw mepc, t0     # entry point into mepc
    mret              # PC <= MEPC; mode <= MPP;
