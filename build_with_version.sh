#!/bin/bash

# Lê a versão atual
VERSION=$(cat version.txt)

# Incrementa a versão automaticamente (exemplo: 1.0.0 -> 1.0.1)
IFS='.' read -r -a version_parts <<< "$VERSION"
PATCH=$((version_parts[2] + 1))
NEW_VERSION="${version_parts[0]}.${version_parts[1]}.$PATCH"
API_URL="https://api.doojob.com.br"

# Salva a nova versão
echo "$NEW_VERSION" > version.txt

# Executa o build com a nova versão
flutter build web --dart-define=APP_VERSION=$NEW_VERSION --dart-define=API_URL=$API_URL

# Substitui $APP_VERSION no index.html do build pela nova versão
sed -i.bak "s|\$APP_VERSION|$NEW_VERSION|g" build/web/index.html

# Remove o arquivo de backup criado pelo sed (.bak)
rm build/web/index.html.bak


echo "Build completed with version $NEW_VERSION"