.globl head_node

.data
head_node:          # Nó 1
    .word 10
    .word -4
    .word node_1    # Aponta para node_1
.skip 10
node_1:             # Nó 2
    .word 56
    .word 78
    .word node_2    # Aponta para node_2
.skip 5
node_2:             # Nó 3
    .word -9138
    .word 1000
    .word node_3    # Aponta para node_3
.skip 5
node_3:             # Nó 4
    .word -100
    .word -43
    .word node_4    # Aponta para node_4

# Continuar adicionando nós intermediários...

node_4:             # Nó 5
    .word 50
    .word 150
    .word node_5
node_5:             # Nó 6
    .word 20
    .word -20
    .word node_6
node_6:             # Nó 7
    .word 70
    .word 200
    .word node_7
node_7:             # Nó 8
    .word -90
    .word -10
    .word node_8
node_8:             # Nó 9
    .word 45
    .word 55
    .word node_9
node_9:             # Nó 10
    .word 30
    .word -5
    .word node_10
node_10:            # Nó 11
    .word 100
    .word -50
    .word node_11
node_11:            # Nó 12
    .word 60
    .word 80
    .word node_12
node_12:            # Nó 13
    .word -300
    .word 400
    .word node_13
node_13:            # Nó 14
    .word -200
    .word 500
    .word node_14
node_14:            # Nó 15
    .word 90
    .word -120
    .word node_15
node_15:            # Nó 16
    .word -80
    .word 20
    .word node_16
node_16:            # Nó 17
    .word 500
    .word -200
    .word node_17
node_17:            # Nó 18
    .word 60
    .word 70
    .word node_18
node_18:            # Nó 19
    .word -150
    .word 150
    .word node_19
node_19:            # Nó 20
    .word 100
    .word -50
    .word node_20
node_20:            # Nó 21
    .word -10
    .word 90
    .word node_21
node_21:            # Nó 22
    .word -70
    .word 80
    .word node_22
node_22:            # Nó 23
    .word 120
    .word -100
    .word node_23
node_23:            # Nó 24
    .word 60
    .word -30
    .word node_24
node_24:            # Nó 25
    .word 200
    .word -100
    .word node_25
node_25:            # Nó 26
    .word -150
    .word 130
    .word node_26
node_26:            # Nó 27 (o nó final com soma de 2981)
    .word -150
    .word 130
    .word node_27          # Fim da lista (próximo nó é 0 para indicar fim)
node_27:
    .word 1000
    .word -10230
    .word 0
