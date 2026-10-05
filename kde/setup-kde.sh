#!/bin/bash
# Optionales Setup fuer KDE Plasma (Wayland):
#  1. KWin-Fensterregel: Fateweaver liegt auf der Overlay-Ebene, auch ueber Vollbild-Spielen.
#  2. Autostart: Fateweaver startet mit AION 2, startet neu wenn geschlossen, endet mit dem Spiel.
# Entfernen: setup-kde.sh --remove
set -euo pipefail
cd "$(dirname "$0")"
GROUP=fateweaver-overlay
SERVICE=aion2-overlay-watcher.service

rules_list() { kreadconfig6 --file kwinrulesrc --group General --key rules; }

if [ "${1:-}" = "--remove" ]; then
  systemctl --user disable --now "$SERVICE" 2>/dev/null || true
  rm -f ~/.config/systemd/user/$SERVICE ~/.local/bin/aion2-overlay-watcher.sh
  systemctl --user daemon-reload
  list=$(rules_list | tr ',' '\n' | grep -vx "$GROUP" | paste -sd, -)
  kwriteconfig6 --file kwinrulesrc --group General --key rules "$list"
  kwriteconfig6 --file kwinrulesrc --group General --key count "$(echo "$list" | tr ',' '\n' | grep -c . || true)"
  sed -i "/^\[$GROUP\]/,/^\[/{/^\[$GROUP\]/d;/^\[/!d}" "${XDG_CONFIG_HOME:-$HOME/.config}/kwinrulesrc"
  qdbus6 org.kde.KWin /KWin reconfigure || true
  echo "Entfernt."
  exit 0
fi

# 1. KWin-Regel (bestehende Regeln bleiben unangetastet)
w() { kwriteconfig6 --file kwinrulesrc --group "$GROUP" --key "$1" "$2"; }
w Description "Fateweaver Overlay"
w wmclass "[fF]ateweaver"
w wmclassmatch 3
w wmclasscomplete false
w layer overlay
w layerrule 2
w above true
w aboverule 2
w desktops ""
w desktopsrule 2
list=$(rules_list)
if ! echo "$list" | tr ',' '\n' | grep -qx "$GROUP"; then
  list=${list:+$list,}$GROUP
  kwriteconfig6 --file kwinrulesrc --group General --key rules "$list"
fi
kwriteconfig6 --file kwinrulesrc --group General --key count "$(echo "$list" | tr ',' '\n' | grep -c .)"
qdbus6 org.kde.KWin /KWin reconfigure
echo "KWin-Regel gesetzt."

# 2. Autostart-Watcher
install -Dm755 aion2-overlay-watcher.sh ~/.local/bin/aion2-overlay-watcher.sh
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/$SERVICE <<UNIT
[Unit]
Description=Fateweaver automatisch mit AION 2 starten
PartOf=graphical-session.target
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/aion2-overlay-watcher.sh
KillMode=process
Restart=always
RestartSec=5

[Install]
WantedBy=graphical-session.target
UNIT
systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE"
echo "Autostart aktiv: Fateweaver startet ab jetzt mit AION 2."
