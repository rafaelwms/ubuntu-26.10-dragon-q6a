## Ubuntu 26.10 "Stonking Stingray" for the Radxa Dragon Q6A — experimental (Linux 7.2.9)

**Experimental, not LTS.** Ubuntu 26.10 is an interim release (about 9 months of support). This is a feasibility port that builds on the learnings of the stable project, [ubuntu-26.04.1-dragon-q6a](https://github.com/rafaelwms/ubuntu-26.04.1-dragon-q6a).

- **Kernel 7.2.9** (mainline, via Armbian `edge`). Linux 7.3.1 boots but has **no video** on this board (DP AUX errors), so it is not used. See `docs/NOTES.md`.
- **Desktop:** GNOME 51, native Firefox (Mozilla `.deb`, no snap), `gnome-software`. Tested on one board: boot from external SSD over USB 3.0 and from the internal NVMe (via rEFInd), HDMI, Wi-Fi, Bluetooth, wired LAN, audio (HDMI and headphone jack), `apt upgrade`, and the NPU base stack (`/dev/fastrpc-*`, adsp/cdsp running). **Not verified yet:** NPU inference (needs the QAIRT SDK) and long-term use. Known cosmetic issue: `systemd-modules-load.service` shows as failed after the first boot; audio works.
- **Server:** not in this release yet; it will be added after hardware testing.

Default login `radxa` / `radxa` (change it). The Desktop image is split into 1400 MiB parts: download all `.part*` files plus both `SHA256SUMS-*.txt`, then use `./install.sh` (Linux) or `./install_mac.sh` (macOS), or concatenate and `dd` by hand (see README).

---

## Ubuntu 26.10 "Stonking Stingray" para a Radxa Dragon Q6A — experimental (Linux 7.2.9)

**Experimental, não é LTS.** O 26.10 é uma versão interim (cerca de 9 meses de suporte). É um port de viabilidade, construído sobre o aprendizado do projeto estável, o [ubuntu-26.04.1-dragon-q6a](https://github.com/rafaelwms/ubuntu-26.04.1-dragon-q6a).

- **Kernel 7.2.9.** O 7.3.1 sobe mas **sem vídeo** nesta placa, por isso não é usado (ver `docs/NOTES.md`).
- **Desktop:** GNOME 51, Firefox nativo (sem snap), `gnome-software`. Testado em uma placa: boot por SSD externo em USB 3.0 e pelo NVMe interno (via rEFInd), HDMI, Wi-Fi, Bluetooth, LAN cabeada, áudio (HDMI e jack de fone), `apt upgrade` e a base da NPU (`/dev/fastrpc-*`, adsp/cdsp rodando). **Ainda não verificados:** inferência na NPU (exige o SDK QAIRT) e uso prolongado. Problema cosmético conhecido: o `systemd-modules-load.service` aparece como falho após o primeiro boot; o áudio funciona.
- **Server:** ainda não está nesta release; entra depois de testado em hardware.

Login padrão `radxa` / `radxa` (troque). A imagem Desktop vem em partes de 1400 MiB: baixe todas as partes `.part*` e os dois `SHA256SUMS-*.txt`, e use `./install.sh` ou `./install_mac.sh`.
