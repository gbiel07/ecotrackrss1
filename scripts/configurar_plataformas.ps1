# Gera as pastas de plataforma (android, ios, web, windows) e aplica os ajustes
# necessários para a câmera. Execute uma única vez, na raiz do projeto:
#   powershell -ExecutionPolicy Bypass -File scripts\configurar_plataformas.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

flutter create . --org br.com.ecotrack --project-name ecotrack_rss --platforms=android,ios,web,windows

# mobile_scanner exige Android 6.0 (API 23) ou superior.
foreach ($file in @('android/app/build.gradle.kts', 'android/app/build.gradle')) {
  if (Test-Path $file) {
    $content = [IO.File]::ReadAllText((Resolve-Path $file))
    $content = $content -replace 'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24'
    $content = $content -replace 'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 24'
    [IO.File]::WriteAllText((Resolve-Path $file), $content)
  }
}

# Permissão de câmera no iOS.
$plist = 'ios/Runner/Info.plist'
if (Test-Path $plist) {
  $content = [IO.File]::ReadAllText((Resolve-Path $plist))
  if ($content -notmatch 'NSCameraUsageDescription') {
    $entry = "`t<key>NSCameraUsageDescription</key>`n`t<string>O EcoTrack RSS usa a câmera para ler o QR Code dos lotes.</string>`n</dict>`n</plist>"
    $content = $content -replace '</dict>\s*</plist>\s*$', $entry
    [IO.File]::WriteAllText((Resolve-Path $plist), $content)
  }
}

flutter pub get
Write-Host ''
Write-Host 'Plataformas configuradas. Rode: flutter run -d chrome (ou escolha um emulador Android).'
