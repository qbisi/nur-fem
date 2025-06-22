{
  lib,
  stdenv,
  version,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "salome-configuration";
  inherit version;

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "configuration";
    tag = "V${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}";
    hash = "sha256-l3BdP8enGI7cC6aomEZEKZXOT4JorERS4K8L/9bQr3k=";
  };

  postPatch = ''
    substituteInPlace cmake/UseOmniORB.cmake \
      --replace-fail "include/salome" "include"
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r cmake $out
  '';

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Configuration module of the SALOME platform";
    homepage = "https://www.salome-platform.org";
    downloadPage = "https://github.com/SalomePlatform/configuration";
    license = with lib.licenses; [ lgpl21Plus ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
