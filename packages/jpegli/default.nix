{
  stdenv,
  lib,
  fetchFromGitHub,
  brotli,
  cmake,
  giflib,
  gperftools,
  gtest,
  libhwy,
  libjpeg,
  libpng,
  libwebp,
  openexr_3,
  pkg-config,
  zlib,
  lcms2,
  enableLibjpeg ? !stdenv.hostPlatform.isWasm,
}:

let
  libjpegFlag = if enableLibjpeg then "ON" else "OFF";
in
stdenv.mkDerivation {
  pname = "jpegli";
  version = "0-unstable-2025-02-11";

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "google";
    repo = "jpegli";
    rev = "bc19ca2393f79bfe0a4a9518f77e4ad33ce1ab7a";
    hash = "sha256-8th+QHLOoAIbSJwFyaBxUXoCXwj7K7rgg/cCK7LgOb0=";
    # There are various submodules in `third_party/`.
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    lcms2
    giflib
    gperftools # provides `libtcmalloc`
    gtest
    libjpeg
    libpng
    libwebp
    openexr_3
    zlib
  ];

  propagatedBuildInputs = [
    brotli
    libhwy
  ];

  cmakeFlags =
    [
      # Disable `benchmark_xl`
      "-DJPEGXL_ENABLE_BENCHMARK=OFF"

      # Disable building docs, because they are for libjxl
      "-DJPEGXL_ENABLE_DOXYGEN=OFF"
      "-DJPEGXL_ENABLE_MANPAGES=OFF"

      "-DJPEGXL_FORCE_SYSTEM_BROTLI=ON"
      "-DJPEGXL_FORCE_SYSTEM_HWY=ON"
      "-DJPEGXL_FORCE_SYSTEM_GTEST=ON"
      "-DJPEGXL_ENABLE_SKCMS=OFF"
      "-DJPEGXL_FORCE_SYSTEM_LCMS2=ON"

      "-DJPEGXL_ENABLE_JPEGLI_LIBJPEG=${libjpegFlag}"
      "-DJPEGXL_INSTALL_JPEGLI_LIBJPEG=${libjpegFlag}"
    ]
    ++ lib.optionals stdenv.hostPlatform.isStatic [
      "-DJPEGXL_STATIC=ON"
    ]
    ++ lib.optionals stdenv.hostPlatform.isAarch32 [
      "-DJPEGXL_FORCE_NEON=ON"
    ];

  patches = [
    ./0000-remove-condition-in-libjpeg.patch
  ];

  # the second substitution fix regex for a2x script
  # https://github.com/libjxl/libjxl/pull/3842
  postPatch = ''
    # Make sure we do not accidentally build against some of the vendored dependencies
    # If it asks you to "run deps.sh to fetch the build dependencies", then you are probably missing a JPEGXL_FORCE_SYSTEM_* flag
    shopt -s extglob
    rm -rf third_party/!(apngdis|libjpeg-turbo|sjpeg)/
    shopt -u extglob

    substituteInPlace CMakeLists.txt \
      --replace 'sh$' 'sh( -e$|$)'
  '';

  CXXFLAGS = lib.optionalString stdenv.hostPlatform.isAarch32 "-mfp16-format=ieee";

  # FIXME x86_64-darwin:
  # https://github.com/NixOS/nixpkgs/pull/204030#issuecomment-1352768690
  doCheck = with stdenv; !(hostPlatform.isi686 || isDarwin && isx86_64);

  meta = with lib; {
    homepage = "https://github.com/google/jpegli";
    description = "An improved JPEG encoder and decoder implementation";
    license = licenses.bsd3;
    maintainers = [];
    platforms = platforms.all;
  };
}
