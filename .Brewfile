brew "bash", trusted: true
brew "brush", trusted: true
brew "direnv", trusted: true
brew "fd", trusted: true
brew "ffmpeg-full", trusted: true
brew "fzf", trusted: true
brew "gh", trusted: true
brew "git", trusted: true
brew "go", trusted: true
brew "gopls", trusted: true
brew "grep", trusted: true
brew "imagemagick-full", trusted: true
brew "jq", trusted: true
brew "lazydocker", trusted: true
brew "lazygit", trusted: true
brew "markdown-oxide", trusted: true
brew "mise", trusted: true
brew "mycli", trusted: true
brew "tree-sitter", trusted: true
brew "tree-sitter-cli", trusted: true
brew "neovim", trusted: true
brew "peco", trusted: true
brew "pnpm", trusted: true
brew "poppler", trusted: true
brew "resvg", trusted: true
brew "ripgrep", trusted: true
brew "sevenzip", trusted: true
brew "the_silver_searcher", trusted: true
brew "tig", trusted: true
brew "tree", trusted: true
brew "xwmx/taps/nb", trusted: true
brew "yazi", args: ["HEAD"], trusted: true
brew "yq", trusted: true
brew "zoxide", trusted: true

# claude-code's cask ships Linux binaries too
cask "claude-code", trusted: true

if OS.mac?
  cask "font-hackgen", trusted: true
  cask "font-hackgen-nerd", trusted: true
  cask "font-jetbrains-mono-nerd-font", trusted: true
  cask "wezterm@nightly", trusted: true
else
  # fonts are installed manually on Linux (see setup-ubuntu.sh); Homebrew casks
  # can't place them. WezTerm ships as a formula in its own Linuxbrew tap instead.
  tap "wezterm/wezterm-linuxbrew"
  brew "wezterm/wezterm-linuxbrew/wezterm", args: ["HEAD"], trusted: true
end
