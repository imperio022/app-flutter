#!/bin/bash
# Script para configurar o keystore localmente
# Execute: chmod +x scripts/setup-keystore.sh && ./scripts/setup-keystore.sh

echo "🔐 Configurando keystore para Império 022..."

cd android

# Gerar keystore
keytool -genkey -v \
  -keystore app-upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias imperio022 \
  -storepass imperio022keystore \
  -keypass imperio022keystore \
  -dname "CN=Império 022, OU=Lava Jato, O=Imperio022, L=Saquarema, ST=RJ, C=BR"

# Criar key.properties
cat > key.properties << EOF
storePassword=imperio022keystore
keyPassword=imperio022keystore
keyAlias=imperio022
storeFile=app-upload-keystore.jks
EOF

echo "✅ Keystore criado com sucesso!"
echo "📦 Para GitHub Actions, execute:"
echo "   base64 android/app-upload-keystore.jks > keystore_base64.txt"
echo "   Copie o conteúdo de keystore_base64.txt para o Secret KEYSTORE_BASE64 no GitHub"
