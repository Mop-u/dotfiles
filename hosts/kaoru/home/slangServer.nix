{
    stdenv,
    fetchgit,
    cmake,
    python3,
    mimalloc,
    catch2_3,
    cpptrace,
    fmt,
}:
stdenv.mkDerivation (finalAttrs: {
    pname = "slang-server";
    version = "0.2.5";
    src = fetchgit {
        url = "https://github.com/hudson-trading/slang-server";
        rev = "v${finalAttrs.version}";
        hash = "sha256-otXgWg7+icsE473i11tjtyNO96ff/tCGTE3+hDEvV28=";
        fetchSubmodules = true;
    };
    nativeBuildInputs = [
        cmake
        python3
        mimalloc
        catch2_3
        cpptrace
        fmt.dev
    ];
    cmakeFlags = [
        "-DCMAKE_DISABLE_FIND_PACKAGE_fmt=0"
        "-DSLANG_SERVER_INCLUDE_TESTS=0"
    ];
    meta = {
        homepage = "https://hudson-trading.github.io/slang-server";
        description = "A high-performance LSP implementation for SystemVerilog, built on top of the Slang frontend";
        mainProgram = "slang-server";
    };
})
