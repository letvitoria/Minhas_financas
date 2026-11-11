#!/usr/bin/env bash
set -euo pipefail
STARTER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT="$(dirname "$STARTER_ROOT")"
TARGET="$PARENT/grana_jovem_app"

if [[ -e "$TARGET" ]]; then
  echo "A pasta '$TARGET' já existe. Renomeie ou remova antes de executar novamente." >&2
  exit 1
fi

flutter create --project-name grana_jovem --platforms android,ios,web "$TARGET"
cp -R "$STARTER_ROOT/lib" "$TARGET/"
cp -R "$STARTER_ROOT/supabase" "$TARGET/"
cp "$STARTER_ROOT/pubspec.yaml" "$STARTER_ROOT/analysis_options.yaml" "$STARTER_ROOT/.gitignore" "$STARTER_ROOT/.env.example" "$STARTER_ROOT/README.md" "$TARGET/"
cp -R "$STARTER_ROOT/scripts" "$TARGET/"
cp "$STARTER_ROOT/.env.example" "$TARGET/.env"

echo "Projeto criado em: $TARGET"
echo "Edite $TARGET/.env, depois execute: cd '$TARGET' && flutter pub get && flutter run"
