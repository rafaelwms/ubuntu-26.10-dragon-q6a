# Notas do port 26.10 (31/10/2026)

Contexto: Ubuntu 26.10 "Stonking Stingray" (codinome `stonking`, lançado em 15/10/2026, versão interim). Base técnica e pesquisa completa:
https://github.com/rafaelwms/ubuntu-26.04.1-dragon-q6a (ver `docs/pesquisa.md` lá).

## Kernel
- O Armbian ainda não tem 7.3 para o qcs6490 (a `edge` do board fica em 7.2.x); usamos a tag do kernel.org (`KERNEL_TAG`).
- **7.2.9 (padrão, funciona):** HDMI, Wi-Fi/BT, apt upgrade OK no Desktop. 13 patches do Armbian `qcs6490-7.2` (o 0010 é descartado: já está no fonte do 7.2.9).
- **7.3.1 (não usar):** 13 dos 14 patches do Armbian aplicam com contexto ajustado (`patches-qcs6490-7.3/`); o 0005 já é upstream. Compila e a DTB também,
  mas o boot fica **sem vídeo** (serial, simpledrm, GPU Adreno a660/GMU e userspace sobem normalmente):
  - `[drm:msm_dp_aux_isr [msm]] *ERROR* Unexpected DP AUX IRQ 0x00000008 when not busy`
  - `msm_dpu ae01000.display-controller: [drm] Cannot find any crtc or sizes`
  Mesma assinatura do bug do 7.0/7.2.3 relatado no fórum da Radxa. Hipóteses: mudanças do driver `msm/dp` no 7.3, ou os patches de DP rebaseados.
  Idéia para depois: diff de `drivers/gpu/drm/msm/dp` entre 7.2.9 e 7.3.1 e testes sem os patches de DP.

## Pipeline: o que quebrou no 26.10 e como foi corrigido
1. **`ubuntu-desktop-minimal` recomenda `firefox` (transição) + `snapd`** e ambos chegam instalados. O passo do Firefox falhava com
   "Packages were downgraded". Agora: `apt-get purge -y snapd firefox`, pin `-1` para `firefox*` e `snapd` do Ubuntu, `install --allow-downgrades firefox`.
2. **`__u128` nos headers do kernel:** o `asm/ptrace.h` de sistema do 26.10 usa `__u128`; as cópias `tools/include/uapi/linux/types.h` e
   `tools/include/linux/types.h` do pacote `linux-headers` do 7.2.9 não definem, e o `postinst` falha em `resolve_btfids`. O passo do Wi-Fi faz
   `dpkg --unpack`, corrige os dois `types.h` e então `dpkg --configure`. (O 7.3.1 não tem o problema: seus headers já definem o tipo.)
3. Codinome `stonking` em `01-build-rootfs.sh`, `03-assemble-image.sh`, `build.sh`, `lib/provision-*.sh`.

## Velocidade do build
O gargalo é o `qemu-aarch64` rodando 1 núcleo (a máquina fica quase ociosa). Mais núcleos não ajudam; builds independentes em paralelo sim.
Ideias: snapshot do rootfs-base (rootfs + desktop + Firefox) para trocar de kernel em ~15 min, e build nativo arm64 com limite de memória no contêiner.

## Observações de hardware
- Sem RTC: o relógio do primeiro boot mostra data antiga até a rede sincronizar.
- No app Recursos do GNOME a CPU aparece só como "Cortex-A55", a GPU fica quase toda `N/D` e não há NPU (a Hexagon usa FastRPC, sem `/dev/accel`).
  Em Configurações > Sobre aparecem corretos (4x A78 + 4x A55, FD643).
