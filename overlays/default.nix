{ ... }:

{
  libjxl-dev = import ./libjxl-dev;
  tailscale-test-failure-workaround = (_: prev: {
    tailscale = prev.tailscale.overrideAttrs (old: {
      checkFlags =
        builtins.map (
          flag:
            if prev.lib.hasPrefix "-skip=" flag
            then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$"
            else flag
        )
        old.checkFlags;
    });
  });
  p7zip-default-unfree = (_: prev: {
    p7zip = prev.p7zip.override { enableUnfree = true; };
  });
}
