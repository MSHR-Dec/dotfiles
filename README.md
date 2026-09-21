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
reload
mise install
```

## Ubuntu / Kubuntu (Desktop)
Packages are managed with [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux), the same `.Brewfile` as macOS. Casks that only exist on macOS (fonts, WezTerm) are skipped automatically and installed another way instead. Review the script before running it — it uses `sudo` (apt, udev rules, `chsh`) and changes your login shell and group membership.
```
./setup-ubuntu.sh
```
After it finishes:
```
reload
# log out and back in (or reboot) so your new "input" group membership takes effect
```
xremap's per-application remaps (`xremap/config.yml`) work out of the box on X11. On Wayland it depends on the desktop:
- GNOME Wayland: install the [xremap GNOME Shell extension](https://extensions.gnome.org/extension/5060/xremap/).
- KDE Plasma Wayland: no extension exists; xremap logs the active window's class/caption to `journalctl --user -u xremap -f` once a filter has been triggered, which you use to write the `application` matchers. See the [xremap docs](https://github.com/xremap/xremap/blob/master/README.md#kde-plasma-wayland).
