calculadora.x: calculadora.o
	ld.lld calculadora.o -o prog.x

calculadora.s: calculadora.c
	clang-17 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax calculadora.c -S -o calculadora.s

calculadora.o: calculadora.s
	clang-17 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax calculadora.s -c -o calculadora.o

