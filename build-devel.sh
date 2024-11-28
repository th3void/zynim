#!/bin/bash
set -e

# Install deps
echo && echo "Install dependencies"
sudo apt update > /dev/null
sudo apt install -y nmap whois dirb dnsenum libc-bin iproute2 xxd iptables coreutils wget curl \
dnsutils traceroute openssl openssh-server xattr libimage-exiftool-perl tor foremost pkg-config \
libssl-dev steghide libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev 7zip \
libayatana-appindicator3-dev librsvg2-dev chromium-browser git > /dev/null

# Install rust if not exists
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# Install data
echo && echo "Install spellbook data"
sudo cp -r --update=none spellbook/ /var/
sudo chown -R $(whoami):$(whoami) /var/spellbook
echo 'export WITCH_SPELLS_ROOT_DIR=/var/spellbook/archive/' >> ~/.bash_profile
export WITCH_SPELLS_ROOT_DIR=/var/spellbook/archive/

# Wordlist
echo && echo "Wordlists and Malware sigs are too big 700Mb so, if you want or need then, just run:"
echo "git clone https://github.com/cosmic-zip/witchcraft-wordlists /var/spellbook/"

# Build binary
echo && echo "Cargo build"
cargo build --release --manifest-path witchcraft/Cargo.toml
chmod +x ./witchcraft/target/release/witchcraft
sudo cp -r ./witchcraft/target/release/witchcraft /bin/witchcraft

echo && echo "Build dist packages"
rm -rf ./dist
mkdir ./dist

echo && echo "Creating the installer"
cp spellbook/archive/scripts/installer.sh dist/
cp spellbook/archive/scripts/uninstall.sh dist/
cp -r ./witchcraft/target/release/witchcraft ./dist/
cp -r spellbook ./dist
zip -r witchcraft.zip dist/ > /dev/null
mv witchcraft.zip dist/
rm -r dist/spellbook  dist/witchcraft

echo && echo "Done!"