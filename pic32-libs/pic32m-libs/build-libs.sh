#! /bin/bash

export PATH=/c/pic32/bin:$PATH

# temporary files for the build
mkdir -p build
export DESTROOT=/c/pic32/staging
# temporary staging directory that holds the mips-elf build chain
mkdir -p $DESTROOT

cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$DESTROOT
make
make install
cd ..

# Copy built libraries and headers to the actual mips-elf toolchain
echo "Copying pic32m-libs to mips-elf toolchain..."

# Create pic32 include directory in mips-elf
mkdir -p /c/pic32/mips-elf/include/pic32

# Copy libraries from staging to mips-elf/lib/
echo "Installing libraries..."
cp -v $DESTROOT/mips-elf/lib/*.a /c/pic32/mips-elf/lib/

# Copy pic32m-libs headers to pic32/ subdirectory
echo "Installing pic32m-libs headers..."
cp -r $DESTROOT/mips-elf/include/pic32m-libs/* /c/pic32/mips-elf/include/pic32/

# Copy additional PIC32-specific headers from parent directory (if they exist)
echo "Installing additional PIC32 platform headers..."
if [ -d "../include" ]; then
    # Copy top-level headers
    find ../include -maxdepth 1 -type f -name "*.h" -exec cp -v {} /c/pic32/mips-elf/include/pic32/ \;
    # Copy sys/ directory if it exists
    if [ -d "../include/sys" ]; then
        mkdir -p /c/pic32/mips-elf/include/pic32/sys
        cp -v ../include/sys/*.h /c/pic32/mips-elf/include/pic32/sys/
    fi
    # Copy machine/ directory if it exists
    if [ -d "../include/machine" ]; then
        mkdir -p /c/pic32/mips-elf/include/pic32/machine
        cp -v ../include/machine/*.h /c/pic32/mips-elf/include/pic32/machine/
    fi
fi

# Copy assembly files if they exist
if [ -d "../include" ]; then
    find ../include -maxdepth 1 -type f -name "*.S" -exec cp -v {} /c/pic32/mips-elf/include/pic32/ \;
fi

echo "Installation complete!"
echo "Libraries installed to: /c/pic32/mips-elf/lib/"
echo "Headers installed to: /c/pic32/mips-elf/include/pic32/"
