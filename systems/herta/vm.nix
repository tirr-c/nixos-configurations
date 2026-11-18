{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    virt-viewer
    quickemu
  ];
}
