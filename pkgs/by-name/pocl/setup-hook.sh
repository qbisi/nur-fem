preCheckHooks+=('setupOpenclCheck')
preInstallCheckHooks+=('setupOpenclCheck')

setupOpenclCheck () {
  export POCL_DEBUG=1
  export OCL_ICD_VENDORS="@out@/etc/OpenCL/vendors"
}
