.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

.section .text
middle_value_int:
    /**
    * Retorna o valor que está na metade do vetor recebido
    *
    * Parâmetros:
    * a0 = endereço para um vetor de inteiros
    * a1 = tamanho do vetor (n)
    *
    * Retorno:
    * o valor que está na metade do vetor recebido
    */
    # Calcula o offset do elemento desejado (levando em conta o tipo do dado)
    srli a1, a1, 1  # Divide o tamanho do vetor ao meio
    slli a1, a1, 2  # Já que números inteiros têm 4 bytes
    add a0, a0, a1  # Desloca o ponteiro de início do vetor para o meio
    lw a0, 0(a0)
    
    ret


middle_value_short:
    /**
    * Retorna o valor que está na metade do vetor recebido
    *
    * Parâmetros:
    * a0 = endereço para um vetor de shorts ("halfs")
    * a1 = tamanho do vetor (n)
    *
    * Retorno:
    * o valor que está na metade do vetor recebido
    */
    # Calcula o offset do elemento desejado (levando em conta o tipo do dado)
    srli a1, a1, 1  # Divide o tamanho do vetor ao meio
    slli a1, a1, 1  # Já que os shorts têm 2 bytes
    add a0, a0, a1  # Desloca o ponteiro de início do vetor para o meio
    lh a0, 0(a0)
    
    ret


middle_value_char:
    /**
    * Retorna o valor que está na metade do vetor recebido
    *
    * Parâmetros:
    * a0 = endereço para um vetor de chars
    * a1 = tamanho do vetor (n)
    *
    * Retorno:
    * o valor que está na metade do vetor recebido
    */
    # Calcula o offset do elemento desejado (levando em conta o tipo do dado)
    srli a1, a1, 1  # Divide o tamanho do vetor ao meio
    add a0, a0, a1  # Desloca o ponteiro de início do vetor para o meio
    lb a0, 0(a0)
    
    ret


value_matrix:
    /**
    * Retorna o valor de uma posição específica de uma matriz (de int) com 12 linhas e 42 colunas
    * A matriz em questão foi passada por valor (não por referência)
    *
    * Parâmetros:
    * a0 = endereço para o primeiro elemento dessa matriz
    * a1 = r (índice da linha)
    * a2 = c (índice da coluna)
    *
    * Retorno:
    * O valor da matriz nessa posição
    */
    li t0, 42       # Número de elementos de cada linha da matriz
    slli t0, t0, 2  # Já que números inteiros possuem 4 bytes
    slli a2, a2, 2  # Já que números inteiros possuem 4 bytes

    # Calcula o offset do elemento desejado na matriz (levanto em conta o tipo do dado)
    mul a1, a1, t0
    add a1, a1, a2
    add a0, a0, a1
    lw a0, 0(a0)

    ret
