#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
CC=gcc
SECONDS=0

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    #make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    ## configure for our board
    #make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    ## build kernel image
    #make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    
    # make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper defconfig all
    
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper defconfig all
    # make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper defconfig all
    # make -j4 ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" mrproper defconfig all
   
    
    
    # build modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    # build device tree
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
    mkdir -p rootfs/bin rootfs/dev rootfs/etc rootfs/home rootfs/lib rootfs/lib64 rootfs/proc rootfs/sbin rootfs/sys rootfs/tmp rootfs/usr rootfs/var
    mkdir -p rootfs/usr/bin rootfs/usr/lib rootfs/usr/sbin
    mkdir -p rootfs/var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    # -----------------------------------????
    
else
    cd busybox
fi

# TODO: Make and install busybox
    make distclean
    make defconfig
    ###make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
    ###make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
    ##make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE"
    ##make CONFIG_PREFIX="$OUTDIR"/rootfs ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" install
    #make CROSS_COMPILE="$CROSS_COMPILE"
    #make CONFIG_PREFIX="${OUTDIR}"/rootfs CROSS_COMPILE="$CROSS_COMPILE" install
    make CROSS_COMPILE="$CROSS_COMPILE"
    make CROSS_COMPILE="$CROSS_COMPILE" CONFIG_PREFIX="${OUTDIR}/rootfs" install

echo "Library dependencies"
#${CROSS_COMPILE}readelf -a /bin/busybox | grep "program interpreter"
#${CROSS_COMPILE}readelf -a /bin/busybox | grep "Shared library"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library"


# TODO: Add library dependencies to rootfs
    #cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
    #cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64
    #cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64
    
    #cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
    
    cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 "$OUTDIR"/rootfs/lib64
    cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 "$OUTDIR"/rootfs/lib64
    cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 "$OUTDIR"/rootfs/lib64
    
    cp /opt/gcc-arm-none/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 "$OUTDIR"/rootfs/lib
    
    
    

# TODO: Make device nodes
    # null device
    # sudo mknod -m 666 /dev/null c 1 3
    sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
    #mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
    
    # console device
    # sudo mknod -m 666 /dev/console c 5 1
    sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1
    #mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
    rm -rf *.o writer
    ${CROSS_COMPILE}${CC} ${FINDER_APP_DIR}/writer.c -o writer

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
    cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home
    cp ${FINDER_APP_DIR}/*.sh ${OUTDIR}/rootfs/home
    #cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home
    #cp ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home
    mkdir -p ${OUTDIR}/rootfs/home/conf
    cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home/conf
    cp ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home/conf
    
    cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/usr/bin
    cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/usr/bin
    

# TODO: Chown the root directory
    cd "$OUTDIR"/rootfs
    find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio

# TODO: Create initramfs.cpio.gz
    gzip -f "$OUTDIR"/initramfs.cpio
    #cp "$OUTDIR"/initramfs.cpio.gz "$OUTDIR"/linux-stable/arch/"$ARCH"/boot/
    cp "$OUTDIR"/linux-stable/arch/"$ARCH"/boot/Image "$OUTDIR"
    
duration=$SECONDS
echo "$((duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
