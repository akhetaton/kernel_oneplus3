#!/bin/bash

#
#  Kernel Build Script!
#  Based off AK's build script - Thanks!
#

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="bane_defconfig"

# Kernel Details
BASE_VER="BaneKernel"
VER="R.10"
VARIANT="$BASE_VER-$VER"

# Vars
export LOCALVERSION=-`echo $VARIANT`
export CROSS_COMPILE=/data/toolchain/aarch64-linux-gnu-7.3.1/bin/aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=crian
export KBUILD_BUILD_HOST=venom

# Paths
KERNEL_DIR=`pwd`
KBUILD_OUTPUT="${KERNEL_DIR}/out"
REPACK_DIR="/data/kernel/AnyKernel2"
ZIP_MOVE="/data/kernel/bk-zips/release"
ZIMAGE_DIR="$KBUILD_OUTPUT/arch/arm64/boot"

# Create output directory
mkdir -p ${KBUILD_OUTPUT}

# Functions
function checkout_branches {
        cd $REPACK_DIR
        git checkout op3-bane
        cd $KERNEL_DIR
}

function clean_all {
        cd $REPACK_DIR
        rm -rf $KERNEL
        rm -rf $DTBIMAGE
        rm -rf zImage
        cd $KERNEL_DIR
        echo
        make O=${KBUILD_OUTPUT} clean && make O=${KBUILD_OUTPUT} mrproper
}

function make_kernel {
        echo
        make O=${KBUILD_OUTPUT} $DEFCONFIG
        make O=${KBUILD_OUTPUT} $THREAD
}

function make_zip {
        cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
        cd $REPACK_DIR
        zip -r9 "$BASE_VER"-OP3-"$VER".zip *
        mv *.zip $ZIP_MOVE
        cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${red}"
echo "----------------------------"
echo "Bane Kernel Creation Script:"
echo "----------------------------"
echo -e "${restore}"

echo

echo -e "${red}"
echo "Cleaning..."
echo -e "${restore}"
checkout_branches
clean_all
echo -e "${green}"
echo "All cleaned now."
echo -e "${restore}"

echo

echo -e "${red}"
echo "Compiling..."
echo -e "${restore}"
make_kernel
echo -e "${green}"
echo "All compiled now."
echo -e "${restore}"

echo

echo -e "${red}"
echo "Zipping..."
echo -e "${restore}"
make_zip
echo -e "${green}"
echo "All zipped now."
echo -e "${restore}"

echo

echo -e "${red}"
echo "-------------------"
echo "Build Completed In:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
