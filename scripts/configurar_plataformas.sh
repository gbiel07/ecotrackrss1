#!/usr/bin/env bash
# Gera as pastas de plataforma (android, ios, web, windows) e aplica os ajustes
# necessários para a câmera. Execute uma única vez, na raiz do projeto:
#   bash scripts/configurar_plataformas.sh
set -euo pipefail
cd "$(dirname "$0")/.."

flutter create . --org br.com.ecotrack --project-name ecotrack_rss --platforms=android,ios,web,windows

# mobile_scanner exige Android 6.0 (API 23) ou superior.
for file in android/app/build.gradle.kts android/app/build.gradle; do
  if [ -f "$file" ]; then
    sed -i.bak -E 's/minSdk[[:space:]]*=[[:space:]]*flutter\.minSdkVersion/minSdk = 24/; s/minSdkVersion[[:space:]]+flutter\.minSdkVersion/minSdkVersion 24/' "$file"
    rm -f "$file.bak"
  fi
done

# Permissão de câmera no iOS.
plist=ios/Runner/Info.plist
if [ -f "$plist" ] && ! grep -q NSCameraUsageDescription "$plist"; then
  python3 - "$plist" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding='utf-8').read()
entry = ('\t<key>NSCameraUsageDescription</key>\n'
         '\t<string>O EcoTrack RSS usa a câmera para ler o QR Code dos lotes.</string>\n'
         '</dict>\n</plist>\n')
text = re.sub(r'</dict>\s*</plist>\s*$', entry, text)
open(path, 'w', encoding='utf-8').write(text)
PY
fi

flutter pub get
echo
echo "Plataformas configuradas. Rode: flutter run -d chrome (ou escolha um emulador Android)."
