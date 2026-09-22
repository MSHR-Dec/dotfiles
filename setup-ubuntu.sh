#! /bin/bash
set -euo pipefail

DIR=$(
  cd $(dirname $0)
  pwd
)

if ! command -v apt-get >/dev/null 2>&1; then
  echo "setup-ubuntu.sh targets apt-based systems (Ubuntu). Aborting." >&2
  exit 1
fi

# Resolves the browser_download_url of the first release asset of "$1"
# (owner/repo) whose filename matches the regex "$2".
_latest_asset_url() {
  local repo="$1" pattern="$2"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" |
    grep -oE '"browser_download_url": *"[^"]+"' |
    sed -E 's/^"browser_download_url": *"//; s/"$//' |
    grep -E "${pattern}" | head -n1
}

echo "==> apt prerequisites"
sudo apt-get update
# build-essential/procps/curl/file/git: required by the Homebrew installer
# unzip: font / xremap release archives, fontconfig: fc-cache
sudo apt-get install -y build-essential procps curl file git unzip fontconfig

echo "==> Homebrew (Linuxbrew)"
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "==> vim-plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "==> Fonts (HackGen / HackGen Nerd / JetBrainsMono Nerd Font)"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "${FONT_DIR}"

_install_font_zip() {
  local url="$1" dest="$2"
  if [ -z "${url}" ]; then
    echo "  skip: could not resolve a download url for ${dest}" >&2
    return
  fi
  if [ -d "${dest}" ]; then
    return
  fi
  local tmp
  tmp=$(mktemp -d)
  curl -fLo "${tmp}/font.zip" "${url}"
  unzip -qo "${tmp}/font.zip" -d "${dest}"
  rm -rf "${tmp}"
}

_install_font_zip "$(_latest_asset_url yuru7/HackGen '/HackGen_v[0-9.]+\.zip$')" "${FONT_DIR}/HackGen"
_install_font_zip "$(_latest_asset_url yuru7/HackGen '/HackGen_NF_v[0-9.]+\.zip$')" "${FONT_DIR}/HackGenNerd"
_install_font_zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "${FONT_DIR}/JetBrainsMonoNerd"

fc-cache -f "${FONT_DIR}" >/dev/null

echo "==> xremap (prebuilt \"full\" release binary)"
if ! command -v xremap >/dev/null 2>&1; then
  mkdir -p ~/.local/bin
  ARCH=$(uname -m)
  XREMAP_URL=$(_latest_asset_url xremap/xremap "xremap-linux-${ARCH}-full\.zip$")
  if [ -n "${XREMAP_URL}" ]; then
    tmp=$(mktemp -d)
    curl -fLo "${tmp}/xremap.zip" "${XREMAP_URL}"
    unzip -qo "${tmp}/xremap.zip" -d "${tmp}"
    install -m 755 "${tmp}/xremap" ~/.local/bin/xremap
    rm -rf "${tmp}"
  else
    echo "  skip: could not resolve an xremap release asset for arch ${ARCH}" >&2
  fi
fi

echo "==> xremap permissions (input group / uinput)"
# https://github.com/xremap/xremap/blob/master/doc/running_without_sudo.md
sudo gpasswd -a "$USER" input
echo 'KERNEL=="event*", NAME="input/%k", MODE="660", GROUP="input"' | sudo tee /etc/udev/rules.d/input.rules >/dev/null
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess", MODE:="0660", OPTIONS+="static_node=uinput"' |
  sudo tee /etc/udev/rules.d/99-input.rules >/dev/null
echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
sudo modprobe uinput || true
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "==> Homebrew packages"
# setup.sh also does this linking, but it runs "nvim --headless +Lazy!" itself,
# so neovim needs to already be installed by the time it runs.
ln -fnsv "${DIR}"/.Brewfile ~/.Brewfile
CUSTOM_BREWFILE="${DIR}"/.Brewfile.local
[ -e "${CUSTOM_BREWFILE}" ] || cp "${CUSTOM_BREWFILE}".template "${CUSTOM_BREWFILE}"
ln -fnsv "${CUSTOM_BREWFILE}" ~/.Brewfile.local
brew bundle install --global
brew bundle install --file="$HOME/.Brewfile.local"

echo "==> linking dotfiles"
"${DIR}"/setup.sh

echo "==> mise"
mise install

echo "==> shell"
BRUSH_PATH="$(brew --prefix)/bin/brush"
grep -qxF "${BRUSH_PATH}" /etc/shells || echo "${BRUSH_PATH}" | sudo tee -a /etc/shells >/dev/null
chsh -s "${BRUSH_PATH}"

echo "==> xremap.service"
systemctl --user daemon-reload

cat <<'EOF'

Done. A few things still need your attention:
  - Log out and back in (or reboot) so your new "input" group membership takes effect.
  - Start a new shell for the brush login shell / Homebrew environment to take effect.
  - For app-specific remaps on GNOME Wayland, install the xremap GNOME Shell extension:
    https://extensions.gnome.org/extension/5060/xremap/
EOF
