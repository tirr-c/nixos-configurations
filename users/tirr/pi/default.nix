{ ... }:

{
  programs.pi-coding-agent = {
    settings = {
      defaultProvider = "openai";
      defaultModel = "gpt-6.1-sol";
      enabledModels = [
        "openai/gpt-6-astra"
        "openai/gpt-6.1-sol"
        "openai/gpt-6.1-terra"
        "openai/gpt-6-luna"
      ];
      modelThinkingLevels = {
        "openai/gpt-6-astra" = "low";
        "openai/gpt-6.1-sol" = "high";
        "openai/gpt-6.1-terra" = "high";
        "openai/gpt-6-luna" = "xhigh";
      };

      showCacheMissNotices = true;

      collapseChangelog = true;
      enableInstallTelemetry = false;
      tuiMode = "fullscreen";
      fullscreenExitOutput = "resume-hint";
      fullscreenScrollbar = "hidden";

      defaultTools = [
        "read"
        "bash"
        "edit"
        "write"
        "grep"
        "find"
        "ls"
        "codemode"
      ];
    };

    context = ./context.md;

    keybindings =
      let
        esc = ["escape" "ctrl+["];
      in
      {
        "app.interrupt" = esc;
        "tui.select.cancel" = esc;
        "tui.altScreen.halfPageUp" = "ctrl+b";
        "tui.altScreen.halfPageDown" = "ctrl+f";
        "tui.altScreen.lineUp" = "ctrl+up";
        "tui.altScreen.lineDown" = "ctrl+down";
        "tui.altScreen.search" = "ctrl+/";
        "tui.altScreen.searchClose" = esc;
      };
  };
}
