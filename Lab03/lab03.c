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


#define STDIN_FD  0
#define STDOUT_FD 1


/**
 * Lê um número decimal de uma string e retorna seu valor numérico.
 *
 * @param str[] A string contendo o número decimal.
 * @param n O número de caracteres a serem lidos da string.
 * @param eh_negativo Indica se o número é negativo (1 para negativo, 0 para positivo).
 * @return O valor numérico do número decimal representado na string.
 */
int le_decimal(char str[], int n, int eh_negativo) {
  int num = 0;

  if (eh_negativo){
    for (int i = 1; i < n; i++){
      num *= 10;
      num += (str[i] - '0');
    }
  }

  else{
    for (int i = 0; i < n; i++){
      num *= 10;
      num += (str[i] - '0');
    }
  }

  return num;
}


/**
 * Converte um caractere representando um dígito hexadecimal em seu valor numérico.
 *
 * @param digito O caractere a ser convertido ('0'-'9', 'a'-'f').
 * @return O valor numérico correspondente ao dígito (0-15).
 */
int digito_para_numero(char digito) {
  if (digito >= '0' && digito <= '9') {
    return digito - '0';
  }
  return digito - 'a' + 10;
}


/**
 * Lê um número hexadecimal de uma string e retorna seu valor numérico.
 *
 * @param str[] A string contendo o número hexadecimal.
 * @param n O número de caracteres a serem lidos da string.
 * @return O valor numérico do número hexadecimal representado na string.
 */
int le_hexa(char str[], int n) {
  int num = 0;
  for (int i = 2; i < n; i++){
    num *= 16; 
    num += digito_para_numero(str[i]);
  }

  return num;
}


/**
 * Converte um número em seu caractere correspondente em hexadecimal.
 *
 * @param num O número a ser convertido (0-15).
 * @return O caractere correspondente ao número.
 */
char numero_para_digito(int num) {
  if (num < 10) {
    return num + '0';
  }
  return num + 'a' - 10;
}


/**
 * Calcula o complemento de 2 de um número.
 *
 * @param num O número a ser invertido.
 * @return O complemento de 2 do número.
 */
int complemento_de_2(int num) {
  return ~num + 1;
}


/**
 * Converte um número em sua representação binária como string.
 *
 * @param num O número a ser convertido.
 * @param str[] A string de saída onde o número binário será armazenado.
 * @param eh_negativo Indica se o número é negativo (1 para negativo, 0 para positivo).
 * @param estourou Indica se o número estorou o máximo de bits que pode ser armazenado.
 * @return O número de caracteres na string de saída (excluindo '\n').
 */
int bin_para_str(unsigned int num, char str[], int eh_negativo, int estourou) {
  str[0] = '0';
  str[1] = 'b';
  int i = 2;

  if (eh_negativo && !estourou){
    num = complemento_de_2(num);
  }

  while (num >= 2) {
    str[i] = (num % 2) + '0';
    num /= 2;
    i++;
  }

  str[i] = (num % 2) + '0';
  i++;
  str[i] = '\n';

  return i - 1;
}


/**
 * Converte um número em sua representação decimal como string.
 *
 * @param num O número a ser convertido.
 * @param str[] A string de saída onde o número decimal será armazenado.
 * @param eh_negativo Indica se o número é negativo (1 para negativo, 0 para positivo).
 * @param estourou Indica se o número estorou o máximo de bits que pode ser armazenado.
 * @return O número de caracteres na string de saída (excluindo '\n').
 */
int dec_para_str(unsigned int num, char str[], int eh_negativo, int estourou) {
  int i = 0;

  if (eh_negativo){
    str[0] = '-';
    i = 1;
  }

  if (estourou){
    num = complemento_de_2(num);
  }

  while (num >= 10) {
    str[i] = (num % 10) + '0';
    num /= 10;
    i++;
  }

  str[i] = (num % 10) + '0';
  i++;
  str[i] = '\n';

  return i - 1;
}


/**
 * Converte um número em sua representação hexadecimal como string.
 *
 * @param num O número a ser convertido.
 * @param str[] A string de saída onde o número hexadecimal será armazenado.
 * @param eh_negativo Indica se o número é negativo (1 para negativo, 0 para positivo).
 * @param estourou Indica se o número estorou o máximo de bits que pode ser armazenado.
 * @return O número de caracteres na string de saída (excluindo '\n').
 */
int hexa_para_str(unsigned int num, char str[], int eh_negativo, int estourou) {
  str[0] = '0';
  str[1] = 'x';
  int i = 2;

  if (eh_negativo && !estourou){
    num = complemento_de_2(num);
  }

  while (num >= 16) {
    str[i] = numero_para_digito(num % 16);
    num /= 16;
    i++;
  }

  str[i] = numero_para_digito(num % 16);
  i++;
  str[i] = '\n';

  return i - 1;
}


/**
 * Converte um número após ter trocado seus bytes (endianness) para string decimal.
 *
 * @param num O número após o swap de endianness.
 * @param str[] A string de saída onde o número decimal será armazenado.
 * @return O número de caracteres na string de saída (excluindo '\n').
 */
int dec_trocado_para_str(unsigned int num, char str[]) {
  int i = 0;

  while (num >= 10) {
    str[i] = (num % 10) + '0';
    num /= 10;
    i++;
  }

  str[i] = (num % 10) + '0';
  i++;
  str[i] = '\n';

  return i - 1;
}


/**
 * Troca os caracteres de uma string de dois em dois.
 * Necessária para realizar a troca de endianness.
 * 
 * @param str[] A string cujos caracteres serão trocados.
 */
void troca_dois_a_dois(char str[]){
    char temp;
    int i = 2;
    int j = 3;

    while (str[i] != '\n' && str[j] != '\n'){
        temp = str[i];
        str[i] = str[j];
        str[j] = temp;
        i += 2;
        j += 2;
    }  
}


/**
 * Inverte os caracteres de uma string dentro do intervalo especificado.
 * Necessária para organizar as representações dos números como strings da forma correta.
 *
 * @param str[] A string a ser invertida.
 * @param ini O índice inicial para a inversão.
 * @param tam O índice final para a inversão.
 */
void inverter(char str[], int ini, int tam){  
  int inicio = ini;
  int fim = tam;
  int temp;

  while (inicio < fim){
    temp = str[inicio];
    str[inicio] = str[fim];
    str[fim] = temp;

    inicio++;
    fim--;
  }
  
}


/**
 * Completa uma string hexadecimal para representar um número de 32 bits, adicionando zeros à esquerda se necessário.
 * Necessária para que a troca de endianness ocorra da forma correta para todo tipo de número
 *
 * @param str[] A string a ser completada.
 * @param tam O tamanho atual da string.
 * @return O novo tamanho da string.
 */
int completa_32bits(char str[], int tam) {
  while (tam < 9){
    str[tam + 1] = '0';
    str[tam + 2] = '\n';
    tam++;
  }
  return tam;
}


int main() {
  char str[20];
  //Número de dígitos lidos
  int n = read(STDIN_FD, str, 20);
  //Número lido na entrada do programa
  int num_lido;
  //Indica se o número lido é negativo ou não
  int eh_negativo = 0;
  //Indica se o número lido em hexadecimal passou da quantidade de bits máxima
  int estourou = 0;
  
  if (str[0] == '0'){
    num_lido = le_hexa(str, n - 1);
    if (num_lido < 0){
      eh_negativo = 1;
    }
    if (num_lido == -1){
      estourou = 1;
    }
  }

  else{
    if (str[0] == '-'){
      eh_negativo = 1;
    }
    num_lido = le_decimal(str, n - 1, eh_negativo);
  }
  
  char saida_bin[40];
  char saida_dec[40];
  char saida_hexa[40];
  char saida_dec_trocado[40];

  int tam_saida_bin = bin_para_str(num_lido, saida_bin, eh_negativo, estourou);
  inverter(saida_bin, 2, tam_saida_bin);
  write(STDOUT_FD, saida_bin, tam_saida_bin + 2);


  int tam_saida_dec = dec_para_str(num_lido, saida_dec, eh_negativo, estourou);
  if (eh_negativo){
    inverter(saida_dec, 1, tam_saida_dec);
  }
  else{
    inverter(saida_dec, 0, tam_saida_dec);
  }
  write(STDOUT_FD, saida_dec, tam_saida_dec + 2);


  int tam_saida_hexa = hexa_para_str(num_lido, saida_hexa, eh_negativo, estourou);
  inverter(saida_hexa, 2, tam_saida_hexa);
  write(STDOUT_FD, saida_hexa, tam_saida_hexa + 2);


  inverter(saida_hexa, 2, tam_saida_hexa);
  tam_saida_hexa = completa_32bits(saida_hexa, tam_saida_hexa);
  troca_dois_a_dois(saida_hexa);
  int num_invertido = le_hexa(saida_hexa, tam_saida_hexa + 1);
  int tam_saida_dec_trocada = dec_trocado_para_str(num_invertido, saida_dec_trocado);
  inverter(saida_dec_trocado, 0, tam_saida_dec_trocada);
  write(STDOUT_FD, saida_dec_trocado, tam_saida_dec_trocada + 2);

  return 0;
}


void _start()
{
  int ret_code = main();
  exit(ret_code);
}
