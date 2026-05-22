{
  lib,
  stdenv,
  symlinkJoin,
  runCommand,
  fetchgit,
  cef-binary,
  libsixel,
  cmake,
  pkg-config,
}:
stdenv.mkDerivation (
  final:
  let
    version = "0.3.4";
    brow6el= fetchgit {
      url = "https://codeberg.org/janantos/brow6el";
      rev = "refs/tags/v${version}";
      hash = "sha256-58NlPdTegk+ZXXbNRwN5JdtjmepJoPb0QeZxHz7WNkI=";
    };
    libcef_dll_wrapper = runCommand "cef-dir" { } ''
      mkdir -p $out
      cp -r ${cef-binary} $out/cef_binary
      cd $out/cef_binary
      mkdir -p build
      cd build
      cmake -DCMAKE_BUILD_TYPE=Release ..
      make libcef_dll_wrapper
    '';
    src = symlinkJoin {
      name = "brow6el_with_cef";
      paths = [
        brow6el
        libcef_dll_wrapper
      ];
    };

  in
  {
    pname = "brow6el";
    inherit version src;
    nativeBuildInputs = [
      cmake
      pkg-config
      libsixel
    ];
  }
)
