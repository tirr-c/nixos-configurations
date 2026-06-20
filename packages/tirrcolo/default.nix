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
    rev = "a48c4b4f821647ef3cc1281dd21393d1f1fa8b5d";
    hash = "sha256-nrtpwOuiIWiiJptFx1+YgTgd4UGL5NQ96PGQ1dspK8Q=";
  };
}
