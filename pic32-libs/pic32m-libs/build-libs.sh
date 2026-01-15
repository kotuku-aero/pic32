#! /bin/bash

export PATH=/c/pic32/bin:$PATH

mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/c/pic32/atom
make
make install
