{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      cascadia-code
      pretendard
      pretendard-jp
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      twemoji-color-font
    ];

    fontDir.enable = true;
    fontconfig = {
      allowBitmaps = false;
      cache32Bit = true;
      defaultFonts = import ./default-fonts.nix;
    };
  };
}
