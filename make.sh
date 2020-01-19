#!/bin/bash
echo "build uboot-kernel"
export export LDFLAGS=""
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
cp -vt iMX8M/ ../uboot-imx/spl/u-boot-spl.bin \
	../uboot-imx/u-boot-nodtb.bin \
	../uboot-imx/u-boot.bin \
	../uboot-imx/arch/arm/dts/est-imx8mm-som2237.dtb
cp -v ../uboot-imx/tools/mkimage iMX8M/mkimage_uboot
mv iMX8M/est-imx8mm-som2237.dtb iMX8M/fsl-imx8mm-evk.dtb
make clean
make SOC=iMX8MM flash_evk

#cd iMX8M && ./print_fit_hab.sh 0x60000 fsl-imx8mm-evk.dtb ; cd ..
echo "Next: dd if=iMX8M/flash.bin of=/dev/sd[x] bs=1K seek=33 skip=0"
