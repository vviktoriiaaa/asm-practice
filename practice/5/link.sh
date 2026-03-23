#!/bin/bash
# Лінкування об'єктного файлу в готовий виконуваний файл
ld -m elf_i386 practice5.o -o practice5

if [ $? -eq 0 ]; then
    echo "Linking successful: practice5 executable created."
else
    echo "Linking failed!"
    exit 1
fi