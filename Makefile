#GCC_ARGS = -Wall -std=gnu99 -g
GCC_ARGS = -Wall -std=gnu99 -O2
OBJ_FILES = gc.o memory.o reader.o printer.o logger.o eval.o buildins.o scanner.o output_stream.o bytecode_compiler.o bytecode_generator.o bytecode_interpreter.o
LINKER_ARGS = -ldl -lgc

run: tests/*.c lisp
	cd tests; make tests

# Main programs
# The -rdynamic flag makes sure that the functions of the main programs are in their
# ELFs .dynsym section. All symbols in this section can be used by shared libraries that
# are loaded later on.
lisp: lisp.c $(OBJ_FILES)
	gcc $(GCC_ARGS) -rdynamic lisp.c $(OBJ_FILES) $(LINKER_ARGS) -o lisp


# Modules
mod_hello: mod_hello.c
	gcc $(GCC_ARGS) -c -fPIC mod_hello.c
	gcc $(GCC_ARGS) -shared mod_hello.o -o mod_hello.so


# Indiviual components
scanner.o: scanner.h scanner.c
	gcc $(GCC_ARGS) -c scanner.c

bytecode_generator.o: bytecode_generator.c bytecode_generator.h bytecode.h memory.o
	gcc $(GCC_ARGS) -c bytecode_generator.c

output_stream.o: output_stream.h output_stream.c
	gcc $(GCC_ARGS) -c output_stream.c

logger.o: logger.h logger.c output_stream.o
	gcc $(GCC_ARGS) -c logger.c

gc.o: gc.h gc.c
	gcc $(GCC_ARGS) -c gc.c

memory.o: memory.h memory.c bytecode.h gc.o logger.o
	gcc $(GCC_ARGS) -c memory.c

reader.o: reader.h reader.c scanner.o logger.o memory.o
	gcc $(GCC_ARGS) -c reader.c

printer.o: printer.h printer.c output_stream.o memory.o
	gcc $(GCC_ARGS) -c printer.c

eval.o: eval.h eval.c logger.o memory.o bytecode_interpreter.o
	gcc $(GCC_ARGS) -c eval.c

bytecode_interpreter.o: bytecode_interpreter.h bytecode_interpreter.c memory.o
	gcc $(GCC_ARGS) -c bytecode_interpreter.c

bytecode_compiler.o: bytecode_compiler.c bytecode_compiler.h bytecode_generator.o logger.o memory.o
	gcc $(GCC_ARGS) -c bytecode_compiler.c

buildins.o: buildins.h buildins.c logger.o memory.o eval.o bytecode_compiler.o
	gcc $(GCC_ARGS) -c buildins.c


dependencies:
	sudo apt-get install gcc make libgc-dev libgc1c2

clean:
	rm -f *.o *.so lisp core
	cd experiments; make clean
	cd tests; make clean