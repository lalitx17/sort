nasm -f elf64 bubble.asm -o bubble.o
ld bubble.o -o bubble
./bubble