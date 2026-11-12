# EcoTrack RSS

**Rastreabilidade de resíduos de serviços de saúde, do setor de origem até a destinação final.**

O EcoTrack RSS é um aplicativo em Flutter para clínicas, hospitais e laboratórios que precisam controlar o descarte de resíduos de serviços de saúde (RSS). Cada lote recebe um código e um QR Code próprios, e a equipe registra cada etapa do caminho (acondicionamento, coleta interna, armazenamento, coleta externa, tratamento e destinação). O gestor acompanha os indicadores em um dashboard, e qualquer desvio, como atraso na coleta ou documento pendente, vira uma ocorrência com prioridade e status.

Esta versão é a migração para Flutter/Dart do protótipo web feito em HTML, CSS e JavaScript, mantendo o mesmo layout, as mesmas telas, os mesmos dados de demonstração e o mesmo formato de armazenamento.

---

## Sumário

1. [Funcionalidades](#funcionalidades)
2. [Tecnologias](#tecnologias)
3. [Arquitetura e organização](#arquitetura-e-organização)
4. [Como executar](#como-executar)
5. [Credenciais de demonstração](#credenciais-de-demonstração)
6. [Testes e análise estática](#testes-e-análise-estática)
7. [Gerar o APK](#gerar-o-apk)
8. [Telas do aplicativo](#telas-do-aplicativo)
9. [Da versão web para o Flutter](#da-versão-web-para-o-flutter)
10. [Dados, privacidade e limitações](#dados-privacidade-e-limitações)
11. [Integrantes](#integrantes)

---

## Funcionalidades

**Perfil Funcionário (operacional)**

- Tela inicial com indicadores do dia, atalhos rápidos e as últimas movimentações feitas pelo usuário.
- Leitura de QR Code pela câmera ou busca manual pelo código do lote (ex.: `RSS-2026-001`).
- Confirmação de movimentação, que atualiza automaticamente o status do lote conforme a etapa escolhida.
- Registro de ocorrências vinculadas a um lote, com tipo, prioridade e descrição.

**Perfil Gestor responsável**

- Dashboard com total de lotes, lotes em andamento, destinações concluídas e ocorrências abertas.
- Gráfico de lotes e movimentações dos últimos seis meses e distribuição por grupo de resíduo (A a E).
- Cadastro de lote com geração do QR Code e impressão da etiqueta em PDF.
- Atualização do status do lote e da ocorrência, sempre registrada no histórico.

**Recursos comuns**

- Consulta de lotes com busca e filtros por status e grupo.
- Histórico completo de movimentações com busca e linha do tempo por lote.
- Central de IA local: assistente por palavras-chave, análise de inconsistências, resumo gerencial e relatório operacional, tudo calculado no próprio dispositivo, sem API paga.
- Exportação de todos os dados em PDF, cópia do resultado e compartilhamento em `.txt`.
- Persistência local: os registros continuam salvos ao fechar o app.
- Estados de carregamento, erro (com opção de tentar novamente ou restaurar os dados de demonstração) e lista vazia em todas as listagens.
- Layout responsivo: barra lateral fixa no computador e tablet, menu em gaveta no celular.

## Tecnologias

| Tecnologia | Uso no projeto |
| --- | --- |
| Flutter 3.27+ e Dart 3.5+ | Interface e lógica do aplicativo (Android, iOS, Web e Windows) |
| [provider](https://pub.dev/packages/provider) | Gerenciamento de estado com `ChangeNotifier` |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Persistência local dos registros (equivalente ao `localStorage` da versão web) |
| [intl](https://pub.dev/packages/intl) + `flutter_localizations` | Datas e números em pt-BR |
| [qr_flutter](https://pub.dev/packages/qr_flutter) | Geração do QR Code de cada lote |
| [mobile_scanner](https://pub.dev/packages/mobile_scanner) | Leitura do QR Code pela câmera |
| [pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing) | Relatório completo em PDF e etiqueta do lote |
| [share_plus](https://pub.dev/packages/share_plus) | Salvar ou compartilhar o relatório em `.txt` |
| DM Sans e Manrope (SIL OFL) | Tipografia, incluída em `assets/fonts` para funcionar offline |

## Arquitetura e organização

O código é separado em três camadas. A camada **data** cuida dos modelos e da persistência, a camada **logic** concentra as regras de negócio e o estado, e a camada **ui** contém apenas telas, diálogos e widgets reutilizáveis. As telas nunca acessam o armazenamento diretamente: elas leem e alteram o estado pelos controladores expostos com `provider`.

```
lib/
├── main.dart                     # Inicializa datas pt-BR e sobe o app
├── app.dart                      # MultiProvider, tema e RootGate (carregando / erro / login / app)
├── core/
│   ├── constants/                # Grupos de resíduo, status, prioridades, etapas
│   ├── theme/                    # Cores, tipografia e decoração dos campos (iguais ao CSS)
│   └── utils/                    # Formatação de datas/números e breakpoints responsivos
├── data/
│   ├── models/                   # WasteLot, Movement, Occurrence, AppUser, EcoTrackData
│   ├── repositories/             # EcoTrackRepository (SharedPreferences)
│   ├── seed/                     # Dados de demonstração do primeiro acesso
│   └── services/                 # AuthService (login de demonstração)
├── logic/
│   ├── auth_controller.dart      # Sessão do usuário
│   ├── ecotrack_controller.dart  # Lotes, movimentações e ocorrências
│   ├── navigation_controller.dart# Página atual do menu
│   ├── local_assistant.dart      # Regras da Central de IA local
│   └── app_page.dart             # Páginas e textos do cabeçalho
├── services/
│   ├── pdf_export_service.dart   # Relatório em PDF e etiqueta com QR Code
│   └── text_file_service.dart    # Copiar e salvar .txt
└── ui/
    ├── dialogs/                  # Modais de lote, movimentação e ocorrência
    ├── screens/                  # login, shell, home, dashboard, lots, movements,
    │                             # occurrences, scan, ai, startup
    └── widgets/                  # Botões, painéis, tabelas, pílulas, grades, toast...
test/
├── local_assistant_test.dart     # Regras do assistente
├── ecotrack_controller_test.dart # Cadastro, movimentação, ocorrências e persistência
└── widget_test.dart              # Login, autenticação e leitura do código do QR
```

Algumas decisões que valem destacar: o `EcoTrackController` atualiza a tela imediatamente e desfaz a alteração se a gravação falhar; o formato JSON salvo é idêntico ao da versão web (chave `ecotrack_rss_v1`); e o assistente local é uma classe Dart pura, sem dependência de Flutter, o que permite testá-lo isoladamente.

## Como executar

### Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.27 ou superior (inclui o Dart). Confira com `flutter --version`.
- Para Android: Android Studio com um emulador ou um celular com depuração USB ativada.
- Para Web: Google Chrome.

### Passo a passo

```bash
# 1. Clonar o repositório
git clone https://github.com/<usuario>/<repositorio>.git
cd ecotrack_rss

# 2. Gerar as pastas de plataforma e instalar as dependências (apenas na primeira vez)
#    Windows (PowerShell):
powershell -ExecutionPolicy Bypass -File scripts\configurar_plataformas.ps1
#    macOS / Linux:
bash scripts/configurar_plataformas.sh

# 3. Executar
flutter run -d chrome          # no navegador
flutter run                    # no emulador ou celular conectado
```

O script do passo 2 roda `flutter create .` para gerar as pastas `android/`, `ios/`, `web/` e `windows/` sem sobrescrever o código, ajusta o `minSdk` do Android para 24 (exigência da leitura de QR Code) e adiciona a permissão de câmera do iOS. Depois de rodá-lo uma vez, faça o commit dessas pastas para que quem clonar o repositório precise apenas de `flutter pub get` e `flutter run`.

> A câmera funciona em Android, iOS e no navegador (via `localhost` ou HTTPS). No Windows a leitura é feita pela busca manual do código, que está sempre disponível.

## Credenciais de demonstração

| Perfil | Usuário | Senha |
| --- | --- | --- |
| Funcionário | `funcionario` | `1234` |
| Gestor responsável | `gestor` | `1234` |

Selecione o perfil correspondente no campo **Perfil de acesso** antes de entrar.

## Testes e análise estática

```bash
flutter analyze   # análise estática com flutter_lints
flutter test      # testes unitários e de widget
```

Os testes cobrem as regras da Central de IA, o cadastro de lotes com código sequencial, a mudança de status ao confirmar uma movimentação, a resolução de ocorrências, a persistência entre sessões, a autenticação e a tela de login.

Observação sobre o `analysis_options.yaml`: a partir do Flutter 3.47 o import `package:flutter/material.dart` passou a ser sinalizado como obsoleto em favor do pacote `material_ui`. O projeto mantém o import tradicional para continuar compilando em versões anteriores do Flutter, por isso o aviso `deprecated_member_use` está desativado com um comentário explicando o motivo.

## Gerar o APK

```bash
flutter build apk --release
```

O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk` e pode ser anexado em um *release* do GitHub como evidência do app publicado.

## Telas do aplicativo

Salve as capturas em `docs/screenshots/` com os nomes abaixo para que apareçam aqui.

| Login | Dashboard do gestor | Tela inicial do funcionário |
| --- | --- | --- |
| ![Login](docs/screenshots/01-login.png) | ![Dashboard](docs/screenshots/02-dashboard.png) | ![Tela inicial](docs/screenshots/03-home.png) |

| Detalhes do lote com QR Code | Leitura de QR Code | Central de IA |
| --- | --- | --- |
| ![Lote](docs/screenshots/04-lote.png) | ![Scanner](docs/screenshots/05-scanner.png) | ![IA](docs/screenshots/06-ia.png) |

| Ocorrências | Versão celular |
| --- | --- |
| ![Ocorrências](docs/screenshots/07-ocorrencias.png) | ![Celular](docs/screenshots/08-mobile.png) |



## Dados, privacidade e limitações

Os registros ficam salvos apenas no dispositivo ou navegador em uso, sem sincronização entre aparelhos. Desinstalar o app ou limpar os dados do navegador apaga os registros, e a tela de erro oferece a restauração dos dados de demonstração. O login é de demonstração e não protege dados reais; uma operação com vários usuários exigiria banco de dados e autenticação no servidor.

A Central de IA não usa modelo generativo. Ela identifica palavras-chave e aplica regras programadas sobre os dados locais, então não interpreta perguntas com a flexibilidade de uma IA online. As verificações são indicativas e não certificam conformidade legal com a RDC ANVISA nº 222/2018; os resultados devem ser revisados pelo responsável técnico.

## Integrantes

| Nome | Papel no projeto | GitHub |
| --- | --- | --- |
| _Nome do integrante 1_ | _Ex.: desenvolvimento Flutter e arquitetura_ | `@usuario` |
| _Nome do integrante 2_ | _Ex.: UI/UX e identidade visual_ | `@usuario` |
| _Nome do integrante 3_ | _Ex.: pitch, mercado e modelo de negócio_ | `@usuario` |
| _Nome do integrante 4_ | _Ex.: testes, vídeo e validação com usuários_ | `@usuario` |

---

Projeto acadêmico desenvolvido para a disciplina de Desenvolvimento de Aplicativos em Flutter.
