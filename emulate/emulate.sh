#!/usr/bin/env bash

# brew install qemu-user-static
# export QEMU=$(which qemu-arm-static)

# brew install qemu
export QEMU=$(which qemu-system-arm)

export IMAGE=../result/rasp-custom.img


# downloading the kernel
export RPI_KERNEL="kernel-qemu-4.19.50-buster"
export RPI_KERNEL_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.19.50-buster"
[[ ! -f "${RPI_KERNEL}" ]] && wget -O "$RPI_KERNEL"  ${RPI_KERNEL_URL}

# download versatile
export RPI_PTB="versatile-pb.dtb"
export RPI_PTB_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/versatile-pb.dtb"
[[ ! -f "${RPI_PTB}" ]] && wget -O "$RPI_PTB"  ${RPI_PTB_URL}


echo "LAUNCHING IMG ON PORT 5022"

${QEMU} -kernel ${RPI_KERNEL} \
	-cpu arm1176 -m 1024 -M versatilepb \
	-dtb ${RPI_PTB} -no-reboot \
    -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
    -device virtio-scsi-pci,id=ROOT_DISK -drive "id=ROOT_DISK,file=${IMAGE},index=1,media=disk,format=raw" \
    -net user,hostfwd=tcp::5022-:22 -net nic



#$QEMU -kernel ${RPI_KERNEL} \
#	-cpu arm1176 -m 256 -M versatilepb \
#	-dtb ${RPI_PTB} -no-reboot \
#    -serial stdio -append "root=/dev/sdb2 panic=1 rootfstype=ext4 rw" \
#    -device virtio-scsi-pci,id=EXT_DISK -drive "id=EXT_DISK,file=blank.dmg,index=1,media=disk,format=raw" \
#    -device virtio-scsi-pci,id=ROOT_DISK -drive "id=ROOT_DISK,file=${IMAGE},index=2,media=disk,format=raw" \
#    -net user,hostfwd=tcp::5022-:22 -net nic
 





