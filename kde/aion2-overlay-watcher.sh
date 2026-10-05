#!/bin/bash
# Haelt Fateweaver offen, solange AION 2 laeuft, und beendet es mit dem Spiel.
# Wird es waehrend des Spiels geschlossen, startet es nach ~2 s neu.
GAME_PATTERN='Win64[\\/]AION2\.exe'
METER=$(command -v fateweaver || echo /usr/bin/fateweaver)
game_was_running=false

while true; do
  if pgrep -f "$GAME_PATTERN" >/dev/null; then
    if ! $game_was_running; then
      game_was_running=true
      sleep 10  # Spiel erst hochkommen lassen
    fi
    if ! pgrep -x fateweaver >/dev/null; then
      GDK_BACKEND=x11 "$METER" >/dev/null 2>&1 &
    fi
  elif $game_was_running; then
    game_was_running=false
    pkill -x fateweaver
  fi
  sleep 2
done
