# Fateweaver für Linux (inoffiziell)

[Fateweaver](https://github.com/ZekeLabs/fateweaver-releases) ist ein Overlay für AION 2: DPS-Meter, Timer für Rifts, Weltbosse und Events, Feldboss-Respawns, Wartungshinweise und eine Daily/Weekly-Checkliste. Offiziell gibt es Fateweaver nur für Windows.

Dieses Repo baut Fateweaver für **CachyOS, Arch, Manjaro und EndeavourOS**. AION 2 läuft dabei über Steam/Proton, Fateweaver nativ unter Linux.

Getestet auf CachyOS mit KDE Plasma 6.7 (Wayland).

## Installation

Das fertige Paket liegt unter [Releases](../../releases). Herunterladen und installieren:

```bash
sudo pacman -U fateweaver-*-x86_64.pkg.tar.zst
```

Das Paket gibt Fateweaver beim Installieren die Berechtigung, die Netzwerkpakete des Spiels mitzulesen (`setcap`). Fateweaver läuft dadurch ohne root. Nicht mit `sudo` starten.

Danach liegt **Fateweaver** im Anwendungsmenü.

**AION 2 auf "Rahmenlos" oder "Fenster" stellen.** Unter Wayland kann sonst nichts über dem Spiel liegen. Mit dem KDE-Setup unten geht es auch im Vollbild.

### Selbst bauen

Wer dem fertigen Paket nicht traut oder eine neue Fateweaver-Version braucht:

```bash
git clone https://github.com/Navonex/fateweaver-linux.git
cd fateweaver-linux
makepkg -si
```

Der erste Build dauert 10 bis 15 Minuten.

## Extras gegenüber dem Original

- **Overlay nur, wenn es gebraucht wird:** Der Meter erscheint, sobald du kämpfst, und bleibt nach Kampfende noch 15 Sekunden. Bei einem Hinweis (Timer, Feldboss) bleibt er 20 Sekunden. Sonst ist er unsichtbar, und Klicks gehen durch aufs Spiel. Timer und Hinweise laufen im Hintergrund weiter.
- **Menü-Knopf oben links** auf dem Monitor des Meters, mit drei Einträgen: Meter immer anzeigen oder automatisch, Timer & Hinweise, Meter-Einstellungen.
- **Einstellungen > Overlay:** Automatik ein/aus, Nachlaufzeit (5 bis 120 Sekunden), Menü-Knopf ein/aus.

Der Code dafür steckt in `0001-overlay-autohide-corner-menu.patch` und wird beim Bauen eingespielt.

## Optional: KDE Plasma

```bash
./kde/setup-kde.sh
```

Das Skript richtet zwei Dinge ein:

1. **Overlay über dem Spiel:** eine KWin-Fensterregel legt Fateweaver auf die Overlay-Ebene, auch über ein Vollbild-Spiel. Deine anderen Fensterregeln bleiben unverändert.
2. **Autostart mit dem Spiel:** ein kleiner Hintergrunddienst startet Fateweaver, sobald AION 2 läuft. Wird es während des Spiels geschlossen, ist es nach etwa 2 Sekunden wieder da. Wenn das Spiel endet, schließt sich auch Fateweaver.

Rückgängig machen: `./kde/setup-kde.sh --remove`

## Was gegenüber Windows anders ist

- Die Zahl am Taskleisten-Symbol fehlt. Das ist die einzige Code-Änderung: die Funktion dafür (`set_overlay_icon`) gibt es unter Linux nicht und wird beim Bauen durch ein No-op ersetzt.
- Keine automatischen Updates. Bei einer neuen Fateweaver-Version `pkgver` und `sha256sums` im `PKGBUILD` anpassen und neu bauen.
- Fateweaver läuft über XWayland (`GDK_BACKEND=x11`). Nur so kann man Klicks durch das Overlay auf das Spiel durchlassen.

## Probleme

| Was passiert | Was tun |
| --- | --- |
| Meter zeigt nichts, Log meldet `CAP_NET_RAW may be required` | `sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/fateweaver` |
| Overlay rutscht hinter das Spiel | Spiel rahmenlos stellen oder `./kde/setup-kde.sh` ausführen |
| Fenster bleibt leer oder weiß | Mit `WEBKIT_DMABUF_RENDERER_FORCE_SHM=1 fateweaver` starten |

Zum Fehlersuchen im Terminal starten: `GDK_BACKEND=x11 fateweaver`

## Lizenz und Herkunft

Fateweaver steht unter GPL-3.0 und stammt von [ZekeLabs](https://github.com/ZekeLabs/fateweaver-releases). Es baut auf [A2Tools DPS Meter](https://github.com/taengu/A2Tools-DPS-Meter) von taengu auf. Dieses Repo ist inoffiziell und hat nichts mit ZekeLabs, A2Tools oder NCSoft zu tun. Gebaut wird aus dem Quellcode-Archiv des offiziellen Releases. Die Prüfsumme dafür steht im `PKGBUILD`.

Lizenz: GPL-3.0, siehe [LICENSE](LICENSE).
