# Grana Jovem — Flutter + Supabase

Starter multiplataforma para gerenciamento de finanças pessoais. A interface usa uma linguagem visual própria com laranja vibrante, superfícies arredondadas e temas claro/escuro, inspirada em padrões comuns de apps financeiros. **Não é um produto oficial nem afiliado ao Banco Inter.**

## Stack

- Flutter (canal `stable`) e Dart 3.9+
- Provider para estado de apresentação
- Supabase Auth + PostgreSQL (via `supabase_flutter`)
- `fl_chart` para gráfico de rosca
- `flutter_dotenv` para configuração local
- Material 3, Google Fonts e `intl`

## O que já está no starter

- Login e cadastro por e-mail/senha com Supabase Auth
- Gate de autenticação e navegação inferior
- Tema claro/escuro alternável
- Dashboard com saldo, ocultação de valores e gráfico de receitas/despesas/investimentos
- Cadastro/listagem de contas a vencer
- Cadastro/listagem de rendas
- Cadastro/listagem de posições de investimento por categoria
- Wishlist com progresso e atualização do valor guardado
- Repositório Supabase separado da camada de UI e estado via Provider
- SQL inicial com tabelas, grants e políticas RLS

> É um MVP inicial: não inclui integração bancária Open Finance, conciliação automática, notificações push, cálculo de rentabilidade real, exportação ou testes de integração. Os valores cadastrados são informados pelo usuário.

## 1. Pré-requisitos

1. Instale o Flutter pelo guia oficial e selecione o canal estável:
   ```bash
   flutter channel stable
   flutter upgrade
   flutter doctor
   ```
2. Instale Android Studio (Android) ou Xcode (iOS/macOS, em macOS).
3. Crie um projeto no [Supabase](https://supabase.com/dashboard).

O `pubspec.yaml` exige Dart 3.9 ou superior. Consulte `flutter --version` se houver incompatibilidade.

## 2. Gerar as pastas nativas do Flutter

O ZIP contém o código-fonte Dart e o schema SQL. As pastas nativas (`android/`, `ios/` e `web/`) são geradas pelo próprio Flutter, conforme a máquina de desenvolvimento.

**Windows PowerShell** — dentro da pasta extraída:
```powershell
.\scripts\bootstrap.ps1
```

**macOS / Linux** — dentro da pasta extraída:
```bash
./scripts/bootstrap.sh
```

Os scripts criam a pasta irmã `grana_jovem_app`, geram o projeto Flutter multiplataforma e copiam os arquivos do starter. Eles não sobrescrevem uma pasta `grana_jovem_app` que já exista.

## 3. Configurar o Supabase

1. No Dashboard do Supabase, abra **Project Settings → API Keys** (ou o painel **Connect**).
2. Copie a **Project URL** e a chave **Publishable** (`sb_publishable_...`).
3. No SQL Editor, execute todo o arquivo `supabase/schema.sql`.
4. Em **Authentication → Providers → Email**, mantenha Email habilitado. Para testes, você pode desativar temporariamente a confirmação de e-mail; em produção, configure SMTP e mantenha a confirmação habilitada.
5. Em **Authentication → URL Configuration**, configure os redirect URLs caso utilize confirmação por link ou recuperação de senha. Este starter usa e-mail/senha sem deep link de recuperação.

### Chaves e segurança

A chave publishable é apropriada para apps cliente. **Nunca coloque `service_role` ou uma secret key no Flutter**, pois o binário do app pode ser inspecionado. A proteção dos dados depende das políticas RLS em `schema.sql`; não remova essas políticas.

## 4. Variáveis de ambiente

Copie o arquivo de exemplo:

**Windows PowerShell**
```powershell
Copy-Item .env.example .env
```

**macOS / Linux**
```bash
cp .env.example .env
```

Edite `.env`:
```dotenv
SUPABASE_URL=https://SEU-PROJETO.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_SUA_CHAVE_PUBLICA
```

O `.env` está no `.gitignore`; não faça commit dele. Importante: em Flutter mobile, arquivos `.env` incluídos como assets ficam empacotados no aplicativo. Isso **não** transforma a chave em segredo. É aceitável apenas para a chave publishable, com RLS corretamente configurada. Para builds de CI/produção, prefira injetar os valores com `--dart-define-from-file` ou pelo pipeline de build e adapte `SupabaseConfig`.

## 5. Instalar dependências e executar

```bash
flutter pub get
flutter analyze
flutter run
```

Para escolher dispositivo:
```bash
flutter devices
flutter run -d <device-id>
```

O app também pode rodar na Web, desde que o Supabase esteja configurado para os domínios de origem aplicáveis.

## 6. Estrutura de pastas

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/supabase_config.dart
│   ├── theme/app_theme.dart
│   └── utils/formatters.dart
├── data/
│   ├── models/finance_models.dart
│   └── repositories/finance_repository.dart
├── features/
│   ├── auth/ (login, cadastro e gate)
│   ├── home/ (dashboard e gráfico)
│   ├── bills/ (contas a vencer)
│   ├── income/ (rendas)
│   ├── investments/ (carteira por categoria)
│   └── wishlist/ (metas de consumo)
├── providers/ (autenticação, finanças e tema)
└── shared/widgets/ (componentes reutilizáveis)
supabase/schema.sql
```

## 7. Modelo de dados

- `transactions`: lançamentos de receita, despesa e investimento
- `bills`: contas e recorrência
- `income_sources`: fontes de renda mensal ou extra
- `investments`: posições informadas pelo usuário por categoria
- `wishlist_goals`: desejos, valor-alvo, valor guardado e prazo

Todas as tabelas financeiras possuem `user_id` e políticas RLS que comparam o proprietário com `auth.uid()`.

## 8. Próximas evoluções recomendadas

1. Criar testes unitários dos modelos, repositórios e Providers.
2. Fazer operações compostas (por exemplo, marcar conta como paga e criar despesa) por RPC transacional no PostgreSQL.
3. Adicionar paginação, filtros por período e estados vazios/erro mais detalhados.
4. Adicionar notificações locais para vencimentos e lembretes de metas.
5. Implementar recuperação de senha e deep links por plataforma.
6. Gerar tipos Dart a partir do schema com Supabase CLI para reduzir o uso de `Map<String, dynamic>`.
7. Avaliar políticas de privacidade, LGPD, backup e observabilidade antes de publicar.

## Observação sobre o saldo

O saldo apresentado é uma estimativa calculada como **rendas cadastradas − despesas lançadas − investimentos informados**. Não representa saldo bancário conectado nem patrimônio líquido auditado. Os dados do gráfico são agregados a partir dos registros cadastrados no app. A recorrência de contas é armazenada como metadado (mensal/anual); a geração automática do próximo vencimento ainda precisa ser implementada.
