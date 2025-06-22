{
  lib,
  newScope,
  hdf5,
  medfile,
  mpi,
  python3Packages,
  mpiSupport ? true,
  guiSupport ? false,
}:
lib.makeScope newScope (self: {
  version = "9.14.0";
  inherit mpi mpiSupport guiSupport;
  vtk = python3Packages.vtk;
  hdf5 = hdf5.override {
    inherit (self) mpi mpiSupport;
    cppSupport = !self.mpiSupport;
  };
  medfile =
    self.callPackage
      (medfile.overrideAttrs { cmakeFlags = [ (lib.cmakeBool "MEDFILE_USE_MPI" self.mpiSupport) ]; })
      .override
      { };
  configuration = self.callPackage ./configuration { };
  bootstrap = self.callPackage ./bootstrap { };
  kernel = self.callPackage ./kernel { };
  smesh = self.callPackage ./smesh { };
  geom = self.callPackage ./geom { };
  commongeomlib = self.callPackage ./commongeomlib { };
  med = self.callPackage ./med { };
  medcoupling = self.callPackage ./medcoupling { };
  netgenplugin = self.callPackage ./netgenplugin { };
  gui = self.callPackage ./gui { };
})
