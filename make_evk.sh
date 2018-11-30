#!/bin/bash

echo "build uboot-kernel"

source /mnt/ben/work_imx8/sdk/install/environment-setup-aarch64-poky-linux
export ARCH=arm64
export CROSS_COMPILE=aarch64-poky-linux-

export export LDFLAGS=""

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
cp -vt iMX8M/ ../uboot-imx/spl/u-boot-spl.bin \
	../uboot-imx/u-boot-nodtb.bin \
	../uboot-imx/u-boot.bin \
	../uboot-imx/arch/arm/dts/fsl-imx8mq-evk.dtb
cp -v ../uboot-imx/tools/mkimage iMX8M/mkimage_uboot
make clean
make SOC=iMX8M DTBS=fsl-imx8mq-evk.dtb flash_hdmi_spl_uboot

cd iMX8M && ./print_fit_hab.sh 0x60000 fsl-imx8mq-evk.dtb ; cd ..
echo "Next: dd if=iMX8M/flash.bin of=/dev/sd[x] bs=1K seek=33 skip=0"

