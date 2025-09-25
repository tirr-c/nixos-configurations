{ ... }:

{
  libjxl-dev = import ./libjxl-dev;
  p7zip-default-unfree = (_: prev: {
    p7zip = prev.p7zip.override { enableUnfree = true; };
  });
}
