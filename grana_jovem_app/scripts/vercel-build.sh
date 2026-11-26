#!/usr/bin/env bash

set -euo pipefail

echo "Instalando Flutter SDK..."

git clone --depth 1 --branch stable \
  https://github.com/flutter/flutter.git /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

echo "Verificando Flutter..."
flutter --version

echo "Configurando Supabase..."

: "${SUPABASE_URL:?SUPABASE_URL não configurada}"
: "${SUPABASE_PUBLISHABLE_KEY:?SUPABASE_PUBLISHABLE_KEY não configurada}"

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY}
EOF

echo "Instalando dependências..."

flutter pub get

echo "Compilando aplicativo Web..."

flutter build web --release

echo "Build concluído com sucesso!"