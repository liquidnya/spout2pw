{
  lib,
  stdenv,
  meson,
  ninja,
  cmake,
  pkgsCross,
  wineWow64Packages,
  mesa,
  pkg-config,
  libgbm,
  libdrm,
  vulkan-loader,
  vulkan-headers,
  pipewire,
  zenity,
  makeWrapper,
  withWine ? wineWow64Packages.staging,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "spoutwire";
  version = "0.3.0";

  src = ./..;

  strictDeps = true;
  __structuredAttrs = true;

  buildInputs = [
    vulkan-headers
    makeWrapper
  ];

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkgsCross.mingwW64.buildPackages.gcc
  ];

  depsBuildBuild = [
    pkg-config
    libgbm
    libdrm
    vulkan-loader
    pipewire
    withWine
  ];

  patches = [
    ./0001-mesa.patch
    ./0002-spoutwire-path.patch
    ./0003-spoutwire-usage.patch
    ./0004-tools-package.patch
  ];

  postPatch = ''
    patchShebangs --build tools/get_wine_path.sh
    chmod +x tools/package.sh
    patchShebangs --build tools/package.sh
    patchShebangs --host misc/spoutwire.sh
  '';

  mesonFlags = [
    "--cross-file=${finalAttrs.src}/misc/x86_64-w64-mingw32.txt"
    (lib.mesonBool "libpipewire_static" false)
  ];

  runtimeInputs = [
    zenity
  ];

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper $out/share/spoutwire/spoutwire.sh $out/bin/spoutwire \
      --argv0 spoutwire \
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeInputs}
  '';

  postFixup = ''
    substituteInPlace $out/share/spoutwire/spoutwire.sh \
      --replace-fail '@MESA_PATH@' "${mesa}" \
      --replace-fail '@SPOUTWIRE_PATH@' "$out"
  '';

  meta = {
    description = "Spout2 to PipeWire video bridge";
    homepage = "https://github.com/tasokait/spout2pw";
    mainProgram = "spoutwire";
    license = lib.licenses.lgpl21Plus;
  };
})
