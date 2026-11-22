{ ... }:

{
  programs.pi-coding-agent = {
    settings = {
      defaultProvider = "openai-codex";
      defaultModel = "gpt-6.2-sol";
      enabledModels = [
        "openai-codex/gpt-6.2-astra"
        "openai-codex/gpt-6.2-sol"
        "openai-codex/gpt-6.1-terra"
        "openai-codex/gpt-6-luna"
      ];
      modelThinkingLevels = {
        "openai-codex/gpt-6.2-astra" = "medium";
        "openai-codex/gpt-6.2-sol" = "high";
        "openai-codex/gpt-6.1-terra" = "high";
        "openai-codex/gpt-6-luna" = "xhigh";
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
