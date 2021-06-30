#!/bin/bash
echo "build uboot-kernel"
export export LDFLAGS=""
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
############build uboot-imx#####################
cd ../uboot-imx
make distclean
make imx8mm_som2237_defconfig 
make -j8
cd -
############build flash.bin#####################
cp -vt iMX8M/ ../uboot-imx/spl/u-boot-spl.bin \
	../uboot-imx/u-boot-nodtb.bin \
	../uboot-imx/u-boot.bin \
	../uboot-imx/arch/arm/dts/est-imx8mm-som2237.dtb
cp -v ../uboot-imx/tools/mkimage iMX8M/mkimage_uboot
mv iMX8M/est-imx8mm-som2237.dtb iMX8M/fsl-imx8mm-evk.dtb
make clean
make SOC=iMX8MM flash_evk
echo "Next: dd if=iMX8M/flash.bin of=/dev/sd[x] bs=1K seek=33 skip=0"
############build linux-imx#####################
cd ../linux-imx
make distclean
make iob2407_defconfig 
make -j8
############build uuu dir#####################
cd -
cp iMX8M/flash.bin ./uuu/
cp ../linux-imx/arch/arm64/boot/Image ./uuu/
cp ../linux-imx/arch/arm64/boot/dts/freescale/est-imx8mm-iob2407-hdmi.dtb ./uuu/est-imx8mm-iob2407.dtb
cd uuu
zip -r ../iob2407-tpu-uuu.zip ./*
cd -

