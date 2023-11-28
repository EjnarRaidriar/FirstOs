#!/bin/bash

SRC_DIR="./src"
BUILD_DIR="./build"

IN_FILE="cmd"
OUT_FILE="cmd"

IMAGE_FILE="os"


# Compile to file to binary
nasm -f bin ${SRC_DIR}/${IN_FILE}.asm -o ${BUILD_DIR}/${OUT_FILE}.bin 

cp ${BUILD_DIR}/${OUT_FILE}.bin ${BUILD_DIR}/${IMAGE_FILE}.img

truncate -s 1440k ${BUILD_DIR}/${IMAGE_FILE}.img

