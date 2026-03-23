#!/bin/bash
# Компіляція сирцевого коду в об'єктний файл для архітектури i386
nasm -f elf32 practice5.asm -o practice5.o

if [ $? -eq 0 ]; then
    echo "Compilation successful: practice5.o created."
else
    echo "Compilation failed!"
    exit 1
fi