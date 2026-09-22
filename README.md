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
exec $SHELL -l
brewi
echo /opt/homebrew/bin/brush | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/brush
reload
mise install
```

## Ubuntu / Kubuntu (Desktop)
```
./setup-ubuntu.sh
```
```
exec $SHELL -l
# log out and back in (or reboot) so your new "input" group membership takes effect
```
```
curl -fsSL https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --yes --dearmor -o /usr/share/keyrings/vivaldi-browser.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/vivaldi-archive.sources
Types: deb
URIs: https://repo.vivaldi.com/archive/deb/
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/vivaldi-browser.gpg
EOF
sudo apt-get update
sudo apt-get install -y vivaldi-stable
```
```
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/wezterm.sources
Types: deb
URIs: https://apt.fury.io/wez/
Suites: *
Components: *
Signed-By: /usr/share/keyrings/wezterm-fury.gpg
EOF
sudo apt-get update
sudo apt-get install -y wezterm-nightly
```
- https://ameblo.jp/ninjav8/entry-12964408729.html
```
apt install fcitx5 fcitx5-config-qt fcitx5-mozc
```
