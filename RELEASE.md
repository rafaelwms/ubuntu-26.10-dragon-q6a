## Ubuntu 26.10 "Stonking Stingray" for the Radxa Dragon Q6A — experimental (Linux 7.2.9)

**Experimental, not LTS.** Ubuntu 26.10 is an interim release (about 9 months of support). This is a feasibility port that builds on the learnings of the stable project, [ubuntu-26.04.1-dragon-q6a](https://github.com/rafaelwms/ubuntu-26.04.1-dragon-q6a).

- **Kernel 7.2.9** (mainline, via Armbian `edge`). Linux 7.3.1 boots but has **no video** on this board (DP AUX errors), so it is not used. See `docs/NOTES.md`.
- **Desktop:** GNOME 51, native Firefox (Mozilla `.deb`, no snap), `gnome-software`. Tested on one board: boot from external SSD over USB 3.0, HDMI, Wi-Fi, Bluetooth, `apt upgrade`. **Not verified yet:** audio, NPU, long-term use, native NVMe boot.
- **Server:** built from the same pipeline, **not tested on hardware yet**.

Default login `radxa` / `radxa` (change it). Images are split into 1400 MiB parts: download all parts of **one** image plus both `SHA256SUMS-*.txt`, then use `./install.sh` (Linux) or `./install_mac.sh` (macOS), or concatenate and `dd` by hand (see README).

---

## Ubuntu 26.10 "Stonking Stingray" para a Radxa Dragon Q6A — experimental (Linux 7.2.9)

**Experimental, não é LTS.** O 26.10 é uma versão interim (cerca de 9 meses de suporte). É um port de viabilidade, construído sobre o aprendizado do projeto estável, o [ubuntu-26.04.1-dragon-q6a](https://github.com/rafaelwms/ubuntu-26.04.1-dragon-q6a).

- **Kernel 7.2.9.** O 7.3.1 sobe mas **sem vídeo** nesta placa, por isso não é usado (ver `docs/NOTES.md`).
- **Desktop:** GNOME 51, Firefox nativo (sem snap), `gnome-software`. Testado em uma placa: boot por SSD externo em USB 3.0, HDMI, Wi-Fi, Bluetooth e `apt upgrade`. **Ainda não verificados:** áudio, NPU, uso prolongado e boot NVMe nativo.
- **Server:** mesmo pipeline, **ainda não testado em hardware**.

Login padrão `radxa` / `radxa` (troque). As imagens vêm em partes de 1400 MiB: baixe todas as partes de **uma** imagem e os dois `SHA256SUMS-*.txt`, e use `./install.sh` ou `./install_mac.sh`.
