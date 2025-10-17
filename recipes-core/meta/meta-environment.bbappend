SUMMARY = "Additional variables for environment files for SDK"

do_install_append() {
   sed -i '/CROSS_COMPILE/a export RDK_FSROOT_PATH="$SDKTARGETSYSROOT"' ${D}${SDKPATH}/environment-setup-${REAL_MULTIMACH_TARGET_SYS}
   sed -i '/CROSS_COMPILE/a export RDK_FSROOT_PATH="$SDKTARGETSYSROOT"' ${SDK_OUTPUT}${SDKPATH}/environment-setup-${REAL_MULTIMACH_TARGET_SYS}
}

BB_HASH_IGNORE_MISMATCH = "1"
