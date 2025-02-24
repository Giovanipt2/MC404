.globl _start
.globl play_note
.globl _system_time

.section .data
.align 2
_system_time: .word 0

.section .bss
.align 4
isr_stack: .skip 32
isr_stack_end:
program_stack: .skip 1024
program_stack_end:

.set GPT_TRIGGER, 0xFFFF0100    # Ativa a leitura do tempo atual do sistema
.set TIME_MS, 0xFFFF0104        # Guarda o tempo (em milisegundos) do momento da última leitura realizada
.set V_TIME, 0xFFFF0108         # GPT gera uma interrupção externa a cada v milisegundos
.set MIDI_TRIGGER, 0xFFFF0300   # Ativa o player para tocar uma nota no canal
.set INSTRUMENT_ID, 0xFFFF0302  # Identificador do instrumento
.set NOTE, 0xFFFF0304           # Nota musical
.set VELOCITY, 0xFFFF0305       # Velocidade da nota
.set DURATION, 0xFFFF0306       # Duração da nota

.section .text
.align 2
play_note:
    /**
    * Através do MIDI Synthesizer, toca uma nota musical
    *
    * Parâmetros:
    * a0 = ch (channel) - int
    * a1 = inst (instrument id) - int
    * a2 = note (musical note) - int
    * a3 = vel (note velocity) - int
    * a4 = dur (note duration) - int
    *
    * Retorno:
    * void
    */
    # Identificador do instrumento
    li t0, INSTRUMENT_ID
    sh a1, 0(t0)

    # Nota musical
    li t0, NOTE
    sb a2, 0(t0)

    # Velocidade da nota
    li t0, VELOCITY
    sb a3, 0(t0)

    # Duração da nota
    li t0, DURATION
    sh a4, 0(t0)

    # Ativa o player para tocar uma nota no canal
    li t0, MIDI_TRIGGER
    sb a0, 0(t0)

    ret


.align 2
main_isr:
    /**
    * Rotina de tratamento de interrupção
    */
    # Salva o contexto
    csrrw sp, mscratch, sp  # Troca sp com mscratch
    addi sp, sp, -16        # Aloca espaço na pilha da ISR
    sw a0, 0(sp)            # Salva a0
    sw a1, 4(sp)            # Salva a1
    sw t0, 8(sp)            # Salva t0

    # Trata a interrupção
    la a0, _system_time     # Pega o endereço de _system_time
    lw t0, 0(a0)            # Carrega o valor de _system_time
    addi t0, t0, 100        # Incrementa _system_time
    sw t0, 0(a0)            # Salva o novo valor de _system_time

    li a1, 100              # Carrega o valor de ms que será usado
    li a0, V_TIME           # Pega o endereço de V_TIME
    sw a1, 0(a0)            # Salva o novo valor de V_TIME

    # Restaura o contexto
    lw t0, 8(sp)            # Recupera t0
    lw a1, 4(sp)            # Recupera a1
    lw a0, 0(sp)            # Recupera a0
    addi sp, sp, 16         # Desaloca espaço da pilha da ISR
    csrrw sp, mscratch, sp  # Desfaz a troca sp com mscratch 

    mret


.align 2
_start:
    # Grava a main_isr em mtvec
    la t0, main_isr
    csrw mtvec, t0

    # Salva em mscratch o endereço do topo da pilha da isr
    la t0, isr_stack_end    
    csrw mscratch, t0

    # Salva em sp o edereço do topo da pilha do programa
    la sp, program_stack_end

    # Habilita as interrupções globalmente
    csrr t0, mstatus    
    ori t0, t0, 0x8     # Máscara para o bit 3 (mstatus.MIE)
    csrw mstatus, t0    # Habilita as interrupções

    # Habilita as interrupções externas
    csrr t1, mie    # Seta o bit 11 (MEIE)
    li t2, 0x800    # do registrador mie
    or t1, t1, t2
    csrw mie, t1

    # Configura o GPT para gerar uma interrupção a cada 100ms
    li t0, 100
    li t1, V_TIME
    sw t0, 0(t1)

    # Chama a função principal do programa que usará essa lib
    jal main
