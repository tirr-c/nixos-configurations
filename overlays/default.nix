{ ... }:

{
  libjxl-dev = import ./libjxl-dev;
  p7zip-default-unfree = (_: prev: {
    p7zip = prev.p7zip.override { enableUnfree = true; };
  });

  libdispatch-disable-swift = (final: prev: {
    swift-corelibs-libdispatch = prev.swift-corelibs-libdispatch.override { useSwift = false; };
  });
}
