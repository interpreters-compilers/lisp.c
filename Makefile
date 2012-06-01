GCC_ARGS = -Wall -std=gnu99 -g
OBJ_FILES = memory.o reader.o printer.o logger.o eval.o buildins.o
LINKER_ARGS = -ldl

run: tests repl
	./tests
	./repl

# Main programs
# The -rdynamic flag makes sure that the functions of the main programs are in their
# ELFs .dynsym section. All symbols in this section can be used by shared libraries that
# are loaded later on.
tests: tests.c $(OBJ_FILES)
	gcc $(GCC_ARGS) -rdynamic tests.c $(OBJ_FILES) $(LINKER_ARGS) -o tests

repl: repl.c $(OBJ_FILES)
	gcc $(GCC_ARGS) -rdynamic repl.c $(OBJ_FILES) $(LINKER_ARGS) -o repl


buildins.o: buildins.h buildins.c memory.o
	gcc $(GCC_ARGS) -c buildins.c

eval.o: eval.h eval.c memory.o logger.o
	gcc $(GCC_ARGS) -c eval.c

printer.o: printer.h printer.c memory.o output_stream.o
	gcc $(GCC_ARGS) -c printer.c

reader.o: reader.h reader.c memory.o scanner.o
	gcc $(GCC_ARGS) -c reader.c

memory.o: memory.h memory.c logger.o
	gcc $(GCC_ARGS) -c memory.c

scanner.o: scanner.h scanner.c
	gcc $(GCC_ARGS) -c scanner.c

logger.o: logger.h logger.c output_stream.o
	gcc $(GCC_ARGS) -c logger.c

output_stream.o: output_stream.h output_stream.c
	gcc $(GCC_ARGS) -c output_stream.c


mod_hello: mod_hello.c
	gcc $(GCC_ARGS) -c -fPIC mod_hello.c
	gcc $(GCC_ARGS) -shared mod_hello.o -o mod_hello.so

mod_bytecode: mod_bytecode.c
	gcc $(GCC_ARGS) -c -fPIC mod_bytecode.c
	gcc $(GCC_ARGS) -shared mod_bytecode.o -o mod_bytecode.so

clean:
	rm -f *.o *.so repl core
	cd experiments; make clean
	cd tests; make clean