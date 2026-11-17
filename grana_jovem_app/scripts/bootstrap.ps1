$ErrorActionPreference = 'Stop'
$starterRoot = Split-Path -Parent $PSScriptRoot
$parent = Split-Path -Parent $starterRoot
$target = Join-Path $parent 'grana_jovem_app'

if (Test-Path $target) {
  throw "A pasta '$target' já existe. Renomeie ou remova a pasta antes de executar novamente."
}

flutter create --project-name grana_jovem --platforms android,ios,web $target
if ($LASTEXITCODE -ne 0) { throw 'flutter create falhou. Confira a instalação do Flutter.' }

$items = @('lib', 'supabase', 'pubspec.yaml', 'analysis_options.yaml', '.gitignore', '.env.example', 'README.md')
foreach ($item in $items) {
  Copy-Item -Path (Join-Path $starterRoot $item) -Destination $target -Recurse -Force
}
Copy-Item -Path (Join-Path $starterRoot 'scripts') -Destination $target -Recurse -Force
Copy-Item -Path (Join-Path $starterRoot '.env.example') -Destination (Join-Path $target '.env') -Force

Write-Host "Projeto criado em: $target" -ForegroundColor Green
Write-Host 'Agora edite o arquivo .env nessa pasta, execute flutter pub get e flutter run.'
