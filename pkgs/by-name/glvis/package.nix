{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
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

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "fixup_bundle" "#fixup_bundle"
  '';

  postBuild = lib.optionals stdenv.hostPlatform.isDarwin ''
    make app
  '';

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

  meta = {
    homepage = "https://glvis.org";
    downloadPage = "https://github.com/glvis/glvis";
    description = "Lightweight tool for accurate and flexible finite element visualization";
    mainProgram = "glvis";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})
