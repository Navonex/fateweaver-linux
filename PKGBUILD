# Inoffizieller Linux-Build von Fateweaver (AION-2-Overlay), https://github.com/ZekeLabs/fateweaver-releases
# Fateweaver selbst ist GPL-3.0 und offiziell nur fuer Windows. Dieses PKGBUILD baut es aus dem
# Quellcode-Archiv des offiziellen Releases und ersetzt nur das Windows-Taskleisten-Badge durch ein No-op.
pkgname=fateweaver
pkgver=0.1.2
pkgrel=2
pkgdesc="Fateweaver: AION 2 Overlay (DPS-Meter, Timer, Feldbosse, Checkliste), inoffizieller Linux-Build"
arch=('x86_64')
url="https://github.com/ZekeLabs/fateweaver-releases"
license=('GPL-3.0-only')
depends=('webkit2gtk-4.1' 'gtk3' 'libpcap' 'libcap' 'hicolor-icon-theme')
makedepends=('rust' 'nodejs' 'npm' 'unzip' 'perl')
install=fateweaver.install
source=("Fateweaver-source-$pkgver.zip::https://github.com/ZekeLabs/fateweaver-releases/releases/download/v$pkgver/Fateweaver-source.zip"
        "0001-overlay-autohide-corner-menu.patch")
noextract=("Fateweaver-source-$pkgver.zip")
sha256sums=('0fb646d4dced1e72a1d1567489cc37cffe172e7faca83ed3c0bc609992911801'
            '7dc9e9452e52a6d3aedc87ffe74c80ed25c0ac75308af58fff20f1fdf1d5a550')
options=('!lto' '!debug')

prepare() {
  rm -rf src-fw
  unzip -q "Fateweaver-source-$pkgver.zip" -d src-fw
  cd src-fw
  # Windows-Taskleisten-Badge (set_overlay_icon) gibt es unter Linux nicht.
  perl -i -pe 's/\bw\.set_overlay_icon\(.*\)\.map_err/Ok::<(), tauri::Error>(()).map_err/' src-tauri/src/fateweaver.rs
  ! grep -q 'set_overlay_icon' src-tauri/src/fateweaver.rs
  # Overlay nur im Kampf/bei Hinweisen, Menue-Knopf oben links, Einstellungen > Overlay.
  patch -p1 --forward < "$srcdir/0001-overlay-autohide-corner-menu.patch"
  # Datendateien, die der public-Ordner braucht (wie im Arch-PKGBUILD von A2Tools).
  mkdir -p public/i18n public/data public/src/data
  cp -r src/data/i18n/* public/i18n/
  cp src/data/skill_icons.json src/data/dot_skill_ids.json public/data/
  cp src/data/skill_icons.json src/data/dot_skill_ids.json public/src/data/
}

build() {
  cd src-fw
  # Portabel bauen: CachyOS setzt sonst target-cpu=native, das Paket liefe dann nur auf der Bau-CPU.
  export RUSTFLAGS="-C opt-level=3 -C target-cpu=x86-64"
  export CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt"
  export CXXFLAGS="$CFLAGS"
  npm install --include=dev --no-audit --no-fund
  npx tauri build --no-bundle
}

package() {
  cd src-fw
  install -Dm755 src-tauri/target/release/fateweaver "$pkgdir/usr/bin/fateweaver"
  install -d "$pkgdir/usr/lib/Fateweaver"
  cp -r src/data "$pkgdir/usr/lib/Fateweaver/data"
  ln -s Fateweaver "$pkgdir/usr/lib/fateweaver"
  install -Dm644 src-tauri/icons/128x128.png "$pkgdir/usr/share/icons/hicolor/128x128/apps/fateweaver.png"
  install -Dm644 /dev/stdin "$pkgdir/usr/share/applications/fateweaver.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Fateweaver
Comment=AION 2 Overlay: DPS-Meter, Timer, Feldbosse, Checkliste
Exec=env GDK_BACKEND=x11 fateweaver
Icon=fateweaver
Categories=Game;Utility;
DESKTOP
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
