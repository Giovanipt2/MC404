int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}


void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}


void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}


void _start()
{
  int ret_code = main();
  exit(ret_code);
}


int le_decimal(char str[], int ini, int fim) {
  int num = 0;

    for (int i = ini; i < fim; i++){
        num *= 10;
        num += (str[i] - '0');
    }

    if (str[ini - 1] == '-')
        num *= -1;

  return num;
}


void hex_code(int val){
    /*
    Transforma um número decimal em uma string hexadecimal

    Parâmetro:
    val -- Número inteiro que será transformado

    Retorno:
    hex -- String representando o número hexadecimal
    */
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}


void pack(int input, int start_bit, int end_bit, int *val){
    /*
    Seleciona quais bits do número dado como input serão usados para montar um novo

    Parâmetros:
    input -- número inteiro do qual serão extraídos os bits
    start_bit -- inteiro que indica qual o primeiro bit selecionado
    end_bit -- inteiro que indical qual o último bit selecionado
    val -- endereço do número que será montado a partir dos demais
    */
   //Número de bits a ser extraído
   int n_bits = end_bit - start_bit;
   //Número que será usado como máscara para a extração
   int mask = 1;

   for (int i = 0; i < n_bits; i++){
        mask <<= 1;
        mask++;
   }

    mask &= input;
    mask <<= start_bit;
    *val |= mask;
}


#define STDIN_FD  0
#define STDOUT_FD 1


int main(){
    char entrada[30];
    int tam_entrada = read(STDIN_FD, entrada, 30);
    int saida;

    int n1 = 0, n2 = 0, n3 = 0, n4 = 0, n5 = 0;
    n1 = le_decimal(entrada, 1, 5);
    n2 = le_decimal(entrada, 7, 11);
    n3 = le_decimal(entrada, 13, 17);
    n4 = le_decimal(entrada, 19, 23);
    n5 = le_decimal(entrada, 25, 29);

    pack(n1, 0, 2, &saida);
    pack(n2, 3, 10, &saida);
    pack(n3, 11, 15, &saida);
    pack(n4, 16, 20, &saida);
    pack(n5, 21, 31, &saida);

    hex_code(saida);

    return 0;
}
