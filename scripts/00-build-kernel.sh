#!/usr/bin/env bash
# Compila o kernel (padrão: 7.2.9, branch "edge" do Armbian com a tag
# fixada em KERNEL_TAG -- o Armbian fixa v7.2.3, nós subimos pro último
# estável 7.x; 7.3.1 também compila mas não dá vídeo) usando o Armbian Build Framework, e copia os .deb
# resultantes pra artifacts/kernel-<branch>-qcs6490/.
#
# Variáveis: KERNEL_BRANCH (edge|current, padrão edge) e KERNEL_TAG (só
# vale pro edge, padrão v7.2.9). Pra voltar ao 6.18.2 validado:
#   KERNEL_BRANCH=current scripts/00-build-kernel.sh
# (ver docs/pesquisa.md §4.7/§4.11 e §6.1-bis: o 7.2.3 quebrou o HDMI.)
#
# Só usamos o `./compile.sh kernel` do Armbian (não o build de imagem
# completo dele) -- clona o framework numa pasta local (armbian-build/,
# ignorada pelo git) se ainda não existir, e usa o cache remoto deles
# (ghcr.io/armbian/os/kernel-qcs6490-current), então geralmente termina em
# ~1 minuto em vez de compilar o kernel do zero.
#
# Idempotente: se os .deb já existirem em artifacts/kernel-current-qcs6490/,
# não faz nada.
#
# Uso: scripts/00-build-kernel.sh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARMBIAN_DIR="$PROJECT_DIR/armbian-build"
KERNEL_BRANCH="${KERNEL_BRANCH:-edge}"
KERNEL_TAG="${KERNEL_TAG:-v7.2.9}"
KERNEL_MM="${KERNEL_MM:-${KERNEL_TAG#v}}"; KERNEL_MM="${KERNEL_MM%.*}"
OUT_DIR="$PROJECT_DIR/artifacts/kernel-${KERNEL_BRANCH}-qcs6490"

if compgen -G "$OUT_DIR"/linux-image-${KERNEL_BRANCH}-qcs6490_*.deb >/dev/null 2>&1; then
	echo ">>> Kernel já compilado em $OUT_DIR -- nada a fazer."
	exit 0
fi

if [ ! -d "$ARMBIAN_DIR" ]; then
	echo ">>> Clonando armbian/build (rasa, só o necessário)..."
	git clone --depth=1 https://github.com/armbian/build.git "$ARMBIAN_DIR"
fi

if [ "$KERNEL_BRANCH" = edge ]; then
	# o family config do Armbian usa `declare -g KERNELBRANCH`, que ganha de
	# qualquer variável de ambiente/CLI -- então trocamos a tag no arquivo
	# (clone local descartável). Sem cache remoto pra essa tag: compila do zero.
	sed -i -E "s#(KERNELBRANCH='tag:)v[0-9.]+'#\1${KERNEL_TAG}'#" \
		"$ARMBIAN_DIR/config/sources/families/qcs6490.conf"
	sed -i -E 's#(KERNEL_MAJOR_MINOR=")7\.[0-9]+(")#\1'"${KERNEL_MM}"'\2#' \
		"$ARMBIAN_DIR/config/sources/families/qcs6490.conf"
	PATCH_DIR="$ARMBIAN_DIR/patch/kernel/archive/qcs6490-${KERNEL_MM}"
	if [ -d "$PROJECT_DIR/patches-qcs6490-${KERNEL_MM}" ]; then
		# O Armbian só tem patches até 7.2. Para 7.3 usamos a nossa série
		# rebaseada em patches-qcs6490-7.3/ (13 patches; o 0005 já é upstream).
		# ATENÇÃO: o 7.3.1 bootou mas SEM vídeo (ver README). Use só p/ pesquisa.
		mkdir -p "$PATCH_DIR"; rm -f "$PATCH_DIR"/*.patch
		cp "$PROJECT_DIR"/patches-qcs6490-${KERNEL_MM}/*.patch "$PATCH_DIR"/
	else
		# 7.2.x: patches do Armbian; o 0010 (drm_edid_connector_update no
		# dp_panel.c) já está no fonte do v7.2.9 e não aplica mais.
		for p in ${KERNEL_DROP_PATCHES-0010-drm-msm-dp-add-missing-drm_edid_connector_update-bef.patch}; do
			rm -fv "$PATCH_DIR/$p"
		done
	fi
	grep -nE "KERNEL_MAJOR_MINOR|KERNELBRANCH='tag:" "$ARMBIAN_DIR/config/sources/families/qcs6490.conf"
fi

echo ">>> Compilando kernel (BOARD=radxa-dragon-q6a BRANCH=$KERNEL_BRANCH)..."
(
	cd "$ARMBIAN_DIR"
	# KERNEL_BTF=no: a etapa de BTF do LD do kernel pede mais RAM do que
	# máquinas com pouca memória (ou sem cache remoto do Armbian disponível)
	# costumam ter livre -- BTF só importa pra ferramentas avançadas de
	# BPF/CO-RE, que não usamos aqui (GPU/áudio/rede não dependem disso).
	./compile.sh kernel BOARD=radxa-dragon-q6a BRANCH="$KERNEL_BRANCH" KERNEL_BTF=no
)

mkdir -p "$OUT_DIR"
FOUND=0
while IFS= read -r -d '' deb; do
	cp "$deb" "$OUT_DIR"/
	FOUND=1
done < <(find "$ARMBIAN_DIR/output" -iname "*-${KERNEL_BRANCH}-qcs6490_*.deb" -print0)

[ "$FOUND" -eq 1 ] || { echo "ERRO: build terminou mas não achei os .deb em $ARMBIAN_DIR/output" >&2; exit 1; }

echo ">>> Pronto:"
ls -la "$OUT_DIR"
