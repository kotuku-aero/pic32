## How to build the pic libraries using mips-elf
#! /bin/base

mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/c/pic32
make
make install
