#!/usr/bin/env bash
# Roda DENTRO do chroot arm64 (via qemu-aarch64-static).
# Instala o Firefox de verdade (.deb nativo arm64, sem snap) direto do
# repositório oficial da Mozilla -- não o pacote de transição da Ubuntu
# (que puxa o snapd inteiro + o Firefox via snap, mais pesado e mais
# lento pra abrir). Ver docs/pesquisa.md.
#
# Chave e passos conforme https://support.mozilla.org/kb/install-firefox-linux
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

EXPECTED_FINGERPRINT="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"

apt-get install -y wget gnupg ca-certificates

install -d -m 700 /root/.gnupg
install -d -m 755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc

GOT_FINGERPRINT="$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/^pub/{getline; gsub(/^ +| +$/,""); print}')"
if [ "$GOT_FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]; then
	echo "ERRO: fingerprint da chave da Mozilla não bate!" >&2
	echo "esperado: $EXPECTED_FINGERPRINT" >&2
	echo "recebido: $GOT_FINGERPRINT" >&2
	exit 1
fi
echo "Fingerprint da chave da Mozilla confere: $GOT_FINGERPRINT"

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
	> /etc/apt/sources.list.d/mozilla.list

# Garante que o repo da Mozilla sempre ganha do pacote de transição da
# Ubuntu (que também se chama "firefox"). O pin 1000 sozinho não basta: o
# unattended-upgrade trocou o .deb nativo pelo pacote de transição (epoch 1:),
# que puxa o snapd. O pin -1 bloqueia o firefox do archive Ubuntu de vez.
cat > /etc/apt/preferences.d/mozilla <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1

Package: snapd
Pin: release o=Ubuntu*
Pin-Priority: -1
EOF

# No Ubuntu 26.10 o ubuntu-desktop-minimal já "Recommends" o firefox de
# transição e o snapd, que chegam instalados no passo do desktop. Removemos
# os dois antes de instalar o Firefox nativo da Mozilla (o pacote da Mozilla
# também se chama "firefox", então a recomendação continua satisfeita).
apt-get purge -y snapd firefox || true
rm -rf /snap /var/lib/snapd /var/snap /root/snap

apt-get update
apt-get install -y --allow-downgrades firefox

echo "=== firefox instalado ==="
dpkg -l firefox
apt-cache policy firefox
