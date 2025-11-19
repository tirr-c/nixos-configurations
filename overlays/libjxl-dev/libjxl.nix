{
  fetchFromGitHub,
  libhwy,
  libjxl,
  libjxlVersion ? "0.12.0-dev",
  libjxlRev ? "4075de9a7dfd8a3d9433ab21f525e5560d25abe1",
  libjxlHash ? "sha256-x7i6DDitNDKQfTg31iS2XLHrHDgZNwWNcS6RK3Y9Iyo=",
  ninja,
}:

let
  libhwy' = libhwy.overrideAttrs {
    version = "1.2.0";
    src = fetchFromGitHub {
      owner = "google";
      repo = "highway";
      rev = "1.2.0";
      hash = "sha256-yJQH5ZkpEdJ6lsTAt6yJSN3TQnVoxNpkbChENaxhcHo=";
    };
  };

  version = "${libjxlVersion}-${libjxlRev}";
  libjxl' = libjxl.override {
    libhwy = libhwy';
    enablePlugins = false;
  };
in

libjxl'.overrideAttrs (prev: {
  inherit version;
  src = fetchFromGitHub {
    owner = "libjxl";
    repo = "libjxl";
    rev = libjxlRev;
    hash = libjxlHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [ninja];
  cmakeFlags = ["-GNinja"] ++ prev.cmakeFlags;

  postPatch = ''
    # Make sure we do not accidentally build against some of the vendored dependencies
    # If it asks you to "run deps.sh to fetch the build dependencies", then you are probably missing a JPEGXL_FORCE_SYSTEM_* flag
    shopt -s extglob
    rm -rf third_party/!(sjpeg)/
    shopt -u extglob

    substituteInPlace plugins/gdk-pixbuf/jxl.thumbnailer \
      --replace '/usr/bin/gdk-pixbuf-thumbnailer' "$out/libexec/gdk-pixbuf-thumbnailer-jxl"
    substituteInPlace CMakeLists.txt \
      --replace 'sh$' 'sh( -e$|$)'
  '';
})
