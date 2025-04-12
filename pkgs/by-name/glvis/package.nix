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
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "glvis";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "glvis";
    repo = "glvis";
    rev = "v${finalAttrs.version}";
    hash = "sha256-C3U1njAgz3eNgBt/Sj8t4OqXj/YCuWkjRJGGN7PklTw=";
  };

  nativeBuildInputs = [
    glm
    cmake
    tinyxxd
    xorg.libXi
  ];

  buildInputs = [
    mfem
    libGL
    SDL2
    glew
    libpng
    freetype
    fontconfig
  ];

  cmakeFlags = [
  ];

  meta = {
    description = "Lightweight tool for accurate and flexible finite element visualization";
    homepage = "http://glvis.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})
