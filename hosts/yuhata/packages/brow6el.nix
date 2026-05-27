{
  lib,
  stdenv,
  symlinkJoin,
  patchelf,
  fetchgit,
  cef-binary,
  libx11,
  glibc,
  bash,
  cmake,
  pkg-config,
  libsixel,
  libz,
  zlib,
}:
stdenv.mkDerivation (
  final:
  let
    version = "0.3.5"; # "0.3.4";
    brow6el = fetchgit {
      url = "https://codeberg.org/janantos/brow6el";
      rev = "771c650"; # "refs/tags/v${version}";
      hash = "sha256-nJXVtffLZ3UhgmC/1QTO3kMoOZ7/j8gx99c2nKpDOms="; # "sha256-58NlPdTegk+ZXXbNRwN5JdtjmepJoPb0QeZxHz7WNkI=";
    };
    cef = cef-binary.override {
      version = "148.0.9";
      gitRevision = "0d9d52a";
      chromiumVersion = "148.0.7778.180";
      srcHashes = {
        aarch64-linux = "";
        x86_64-linux = "sha256-k8TnU9qgVP97WBi/3WvQ/5UKJEH5WktzpEHNJdYY8kw=";
      };
    };
    libcef_dll_wrapper = stdenv.mkDerivation (cefFinal: {
      version = cefFinal.src.version;
      pname = "libcef_dll_wrapper";
      src = cef;
      nativeBuildInputs = [ cmake ];
      buildPhase = ''
        make libcef_dll_wrapper
      '';
      installPhase = ''
        mkdir -p $out/cef_binary
        cp -r ${cefFinal.src}/. $out/cef_binary
        mkdir -p $out/cef_binary/build
        cp -r ./ $out/cef_binary/build/
      '';
    });

    rpath = "${cef}/Release:${
      lib.makeLibraryPath [
        libx11
        libz
        libsixel
        glibc
        stdenv.cc.cc.lib
      ]
    }";

  in
  {
    pname = "brow6el";
    inherit version;
    src = symlinkJoin {
      name = "brow6el-src-with-libcef";
      paths = [
        brow6el
        libcef_dll_wrapper
      ];
    };
    nativeBuildInputs = [
      patchelf
      bash
      cmake
      pkg-config
      zlib
      libx11
      libsixel
    ];
    postPatch = ''
      sed -i 's/^set(CMAKE_CXX_STANDARD 17)$/set(CMAKE_CXX_STANDARD 20)/g' ./CMakeLists.txt
    '';
    installPhase = ''
      ls ..
      mkdir -p $out/usr/lib/brow6el
      cp brow6el $out/usr/lib/brow6el
      patchelf --set-rpath "${rpath}" $out/usr/lib/brow6el/brow6el

      cp -r locales $out/usr/lib/brow6el
      cp -r scripts $out/usr/lib/brow6el
      cp *.pak $out/usr/lib/brow6el 2>/dev/null || true
      cp *.bin $out/usr/lib/brow6el 2>/dev/null || true
      cp *.dat $out/usr/lib/brow6el 2>/dev/null || true
      cp *.js $out/usr/lib/brow6el 2>/dev/null || true

      mkdir -p $out/bin
      ln -s $out/usr/lib/brow6el/brow6el $out/bin/brow6el
    '';
  }
)
