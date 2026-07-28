# Império 022 - App Flutter

![Build APK](https://github.com/imperio022/app-flutter/actions/workflows/build-apk.yml/badge.svg)
![Test](https://github.com/imperio022/app-flutter/actions/workflows/test.yml/badge.svg)

## Sistema de Gestão Automotiva para Lava Jato

Aplicativo nativo Flutter para gerenciar todas as operações do lava jato Império 022.

## Funcionalidades

- **Entrada de Veículos** — Registro com placa, tipo, modelo, cor e dados do cliente
- **Gestão de Pátio** — Controle de veículos com tempo de permanência
- **Saída** — Finalização com recibo PDF, QR Code PIX e avaliação
- **Dashboard** — Métricas em tempo real
- **Caixa** — Fluxo financeiro (PIX e Dinheiro)
- **Comissões** — Controle de comissões por funcionário
- **Clientes** — Cadastro e programa de fidelidade
- **Administração** — Gestão de funcionários e configurações
- **Relatórios** — Exportação PDF de dados financeiros
- **Inteligência** — Dados analíticos e gráficos
- **Estoque** — Controle de produtos com alerta de reposição
- **Agendamentos** — Sistema de agendamento online
- **Danos** — Registro fotográfico antes/depois
- **Qualidade** — Checklist de qualidade do serviço
- **Desempenho** — Métricas por funcionário
- **Assinaturas** — Planos mensais de lavagem
- **Escala** — Escala semanal da equipe
- **Clima** — Previsão do tempo em tempo real
- **Modo Offline** — Funcionalidade sem internet
- **Financeiro** — Visão consolidada de receitas e despesas

## Stack

| Tecnologia | Versão |
|-----------|--------|
| Flutter | 3.24+ |
| Dart | 3.0+ |
| State Management | Riverpod |
| Navigation | GoRouter |
| HTTP | Dio + http |
| UI | Material 3 + Google Fonts |
| Charts | fl_chart |
| Camera | mobile_scanner |
| Local Storage | Hive + SharedPreferences |
| Auth | JWT via secure storage |

## Arquitetura

```
lib/
├── main.dart              # Entry point
├── app.dart               # Configuração do MaterialApp
├── core/
│   ├── constants.dart     # Cores, preços, configs
│   ├── theme.dart         # Tema Automotive Noir
│   ├── router.dart        # Rotas (GoRouter)
│   ├── models.dart        # Modelos de dados
│   └── api_service.dart   # Cliente HTTP
├── providers/
│   ├── auth_provider.dart # Autenticação
│   └── data_provider.dart # Dados do backend
└── screens/
    ├── login_screen.dart
    ├── home_screen.dart
    ├── dashboard_screen.dart
    ├── entry_screen.dart
    ├── patio_screen.dart
    ├── exit_screen.dart
    ├── commission_screen.dart
    ├── cash_screen.dart
    ├── clients_screen.dart
    ├── admin_screen.dart
    ├── reports_screen.dart
    ├── intelligence_screen.dart
    ├── inventory_screen.dart
    ├── appointments_screen.dart
    ├── damage_screen.dart
    ├── quality_screen.dart
    ├── performance_screen.dart
    ├── subscriptions_screen.dart
    ├── schedule_screen.dart
    ├── weather_screen.dart
    ├── offline_screen.dart
    ├── finance_screen.dart
    └── settings_screen.dart
```

## GitHub Actions

O projeto inclui dois workflows automatizados:

### Build APK
Triggers: push na main, pull request, ou manual.
Gera o APK release e cria uma Release no GitHub automaticamente.

### Test & Lint
Triggers: push e pull request na main.
Executa `flutter analyze` e `flutter test`.

## Instalação

```bash
# Clonar
git clone https://github.com/imperio022/app-flutter.git
cd app-flutter

# Instalar dependências
flutter pub get

# Rodar em desenvolvimento
flutter run

# Build APK
flutter build apk --release

# Build para Play Store
flutter build appbundle --release
```

## Configuração do Backend

Altere a URL do backend em `lib/core/constants.dart`:

```dart
static const String baseUrl = 'https://seu-backend.com';
```

## Licença

MIT
