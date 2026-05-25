{
  lib,
  stdenv,
  symlinkJoin,
  fetchgit,
  cef-binary,
  libx11,
  cmake,
  pkg-config,
  auto-patchelf,
  libsixel,
  cairo,
  nss,
  alsa-lib,
  pango,
}:
stdenv.mkDerivation (
  final:
  let
    version = "0.3.4";
    brow6el = fetchgit {
      url = "https://codeberg.org/janantos/brow6el";
      rev = "refs/tags/v${version}";
      hash = "sha256-58NlPdTegk+ZXXbNRwN5JdtjmepJoPb0QeZxHz7WNkI=";
    };
    libcef_dll_wrapper = stdenv.mkDerivation {
      version = cef-binary.version;
      pname = "libcef_dll_wrapper";
      src = cef-binary;
      nativeBuildInputs = [ cmake ];
      buildPhase = ''
        make libcef_dll_wrapper
      '';
      installPhase = ''
        mkdir -p $out/cef_binary
        cp -r ${cef-binary}/. $out/cef_binary
        mkdir -p $out/cef_binary/build
        cp -r ./ $out/cef_binary/build/
      '';
    };
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
      libx11
      libsixel
    ];
    buildInputs = [
      libsixel
      cairo
      nss
      alsa-lib
      pango
    ];
    cmakeFlags = [ "-DCMAKE_SKIP_BUILD_RPATH=ON" ];
    buildPhase = ''
      ./build_appimage.sh
    '';
    installPhase = ''
      mkdir -p $out
      cp -r ./ $out/
    '';
  }
)
