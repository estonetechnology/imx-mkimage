#!/bin/sh
#
# script to generate FIT image source for i.MX8MQ boards with
# ARM Trusted Firmware and multiple device trees (given on the command line)
#
# usage: $0 <dt_name> [<dt_name> [<dt_name] ...]

[ -z "$BL31" ] && BL31="bl31.bin"

if [ ! -f $BL31 ]; then
	echo "WARNING: BL31 file $BL31 NOT found, resulting binary is non-functional" >&2
	BL31=/dev/null
fi

BL32="tee.bin"

if [ ! -f $BL32 ]; then
	BL32=/dev/null
else
	echo "Building with TEE support, make sure your bl31 is compiled with spd. If you do not want tee, please delete tee.bin" >&2
fi

BL33="u-boot-nodtb.bin"

if [ ! -f $BL33 ]; then
	echo "WARNING: $BL33 file NOT found" >&2
	exit 0
fi

cat << __HEADER_EOF
/dts-v1/;

/ {
	description = "Configuration to load ATF before U-Boot";

	images {
		uboot@1 {
			description = "U-Boot (64-bit)";
			data = /incbin/("$BL33");
			type = "standalone";
			arch = "arm64";
			compression = "none";
			load = <0x40200000>;
		};
		atf@1 {
			description = "ARM Trusted Firmware";
			data = /incbin/("$BL31");
			type = "firmware";
			arch = "arm64";
			compression = "none";
			load = <0x00910000>;
			entry = <0x00910000>;
		};
__HEADER_EOF

if [ -f $BL32 ]; then
cat << __HEADER_EOF
		tee@1 {
			description = "TEE firmware";
			data = /incbin/("$BL32");
			type = "firmware";
			arch = "arm64";
			compression = "none";
			load = <0xfe000000>;
			entry = <0xfe000000>;
		};
__HEADER_EOF
fi

cnt=1
for dtname in $*
do
	cat << __FDT_IMAGE_EOF
		fdt@$cnt {
			description = "$(basename $dtname .dtb)";
			data = /incbin/("$dtname");
			type = "flat_dt";
			compression = "none";
		};
__FDT_IMAGE_EOF
cnt=$((cnt+1))
done

cat << __CONF_HEADER_EOF
	};
	configurations {
		default = "config@1";

__CONF_HEADER_EOF

cnt=1
for dtname in $*
do
if [ -f $BL32 ]; then
cat << __CONF_SECTION_EOF
		config@$cnt {
			description = "$(basename $dtname .dtb)";
			firmware = "uboot@1";
			loadables = "atf@1", "tee@1";
			fdt = "fdt@$cnt";
		};
__CONF_SECTION_EOF
else
cat << __CONF_SECTION1_EOF
		config@$cnt {
			description = "$(basename $dtname .dtb)";
			firmware = "uboot@1";
			loadables = "atf@1";
			fdt = "fdt@$cnt";
		};
__CONF_SECTION1_EOF
fi
cnt=$((cnt+1))
done

cat << __ITS_EOF
	};
};
__ITS_EOF