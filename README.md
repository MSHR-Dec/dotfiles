## Mac
```
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
```
./setup.sh
brewi
echo /opt/homebrew/bin/brush | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/brush
anyenv init
anyenv install --init
```

## Manjaro Linux (KDE)
```
sudo pacman -Syyu
sudo pacman -S --needed \
  base-devel bash brush direnv fd ffmpeg fzf github-cli go grep imagemagick jq \
  lazygit tree-sitter neovim peco pnpm poppler resvg ripgrep p7zip \
  the_silver_searcher tig tree vivaldi vivaldi-ffmpeg-codecs yay yazi yq zoxide
yay -S --needed \
  anyenv lazydocker-bin tree-sitter-cli \
  ttf-hackgen ttf-hackgen-nerd wezterm-nightly-bin xremap-kde-bin
go install golang.org/x/tools/gopls@latest
curl -fsSL https://claude.ai/install.sh | bash
```
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/git
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -O ~/.config/git/git-completion.bash
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.config/git/git-prompt.sh
```
```
./setup.sh
chsh -s /usr/bin/brush
anyenv init
anyenv install --init
# xremap (KDE Wayland)
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/99-input.rules
systemctl --user start xremap.service
systemctl --user enable xremap.service
```
