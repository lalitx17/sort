if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename without extension>"
    exit 1
fi

name="$1"
nasm -f elf64 "$name.asm" -o "$name.o"
ld "$name.o" -o "$name"
./"$name"