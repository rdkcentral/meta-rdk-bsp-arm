# Raspberry Pi bootstage for universal image

The `rpi-bootfiles` refer to the firmware a Raspberry Pi machine
loads from the SD card to configure the system
(referred to as BL0/BL1), to hand off to the bootloader (BL3).

These files are imported from [meta-raspberrypi](https://git.yoctoproject.org/meta-raspberrypi). 

Due to the different machine setups for the
Universal Arm image and Raspberry Pi, meta-rdk-bsp-arm cannot
use the rpi-bootfiles from meta-raspberrypi directly.

