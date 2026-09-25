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
cask "claude-code@latest", trusted: true

brew "wl-clipboard", trusted: true unless OS.mac?

# fonts and WezTerm are macOS-only here; on Linux, fonts are installed manually
# and WezTerm comes from its apt repo instead (see README)
if OS.mac?
  cask "font-hackgen", trusted: true
  cask "font-hackgen-nerd", trusted: true
  cask "font-jetbrains-mono-nerd-font", trusted: true
  cask "wezterm@nightly", trusted: true
end
