{
  fetchFromGitHub,
  vimUtils,
  ...
}:

vimUtils.buildVimPlugin {
  name = "tirrcolo";
  src = fetchFromGitHub {
    owner = "tirr-c";
    repo = "tirrcolo";
    rev = "018fdf2c70ef182d51391fc9c49eeeb00c42ef0b";
    hash = "sha256-GrbSvIZyVDmm6e9YIN4+orNTfuuZIpf1YGp9HqUnN+A=";
  };
}
