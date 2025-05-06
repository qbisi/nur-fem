{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  tinyxxd,
  mfem,
  glm,
  libGL,
  SDL2,
  xorg,
  glew,
  libpng,
  freetype,
  fontconfig,
  llvmPackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "glvis";
  version = "4.4";

  src = fetchFromGitHub {
    owner = "glvis";
    repo = "glvis";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1wAo/1p2guemzaoqVo9lNTiAHFC2X10Xj3Xw7Xwt1Kg=";
  };

  nativeBuildInputs = [
    glm
    cmake
    tinyxxd
  ];

  buildInputs =
    [
      mfem
      libGL
      SDL2
      glew
      libpng
      freetype
      fontconfig
      xorg.libXi
      xorg.libX11
    ]
    ++ lib.optionals stdenv.cc.isClang [
      llvmPackages.openmp
    ];

  cmakeFlags = [
  ];

  meta = {
    description = "Lightweight tool for accurate and flexible finite element visualization";
    homepage = "http://glvis.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    broken = stdenv.hostPlatform.isDarwin;
    platforms = lib.platforms.unix;
  };
})
