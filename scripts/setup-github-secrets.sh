#!/bin/bash
# Script para configurar os GitHub Secrets necessários
# Execute: chmod +x scripts/setup-github-secrets.sh && ./scripts/setup-github-secrets.sh
# Requer: gh CLI autenticado

echo "🔧 Configurando GitHub Secrets para Império 022..."

# Gerar keystore base64
KEYSTORE_BASE64=$(base64 android/app-upload-keystore.jks)

# Configurar secrets
gh secret set KEYSTORE_BASE64 --body "$KEYSTORE_BASE64"
gh secret set KEYSTORE_PASSWORD --body "imperio022keystore"
gh secret set KEYSTORE_ALIAS --body "imperio022"
gh secret set KEYSTORE_KEY_PASSWORD --body "imperio022keystore"

echo "✅ Secrets configurados com sucesso!"
echo "📱 Agora faça push na main para gerar o APK automaticamente"
