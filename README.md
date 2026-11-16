# EcoTrack RSS

**Rastreabilidade de resíduos de serviços de saúde, do setor de origem até a destinação final.**

O **EcoTrack RSS** é um aplicativo desenvolvido em Flutter para clínicas, hospitais e laboratórios que precisam controlar o descarte de resíduos de serviços de saúde (RSS).

Cada lote recebe um código e um QR Code próprio, e a equipe registra cada etapa do caminho: acondicionamento, coleta interna, armazenamento, coleta externa, tratamento e destinação. O gestor acompanha os indicadores em um dashboard, e qualquer desvio, como atraso na coleta ou documento pendente, pode gerar uma ocorrência com prioridade e status.

Esta versão é a migração para **Flutter/Dart** do protótipo web desenvolvido anteriormente em HTML, CSS e JavaScript, mantendo a mesma proposta funcional, os dados de demonstração e o formato de armazenamento local.

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

### Perfil Funcionário (operacional)

- Tela inicial com indicadores do dia, atalhos rápidos e as últimas movimentações realizadas pelo usuário.
- Leitura de QR Code pela câmera ou busca manual pelo código do lote (ex.: `RSS-2026-001`).
- Confirmação de movimentação, que atualiza automaticamente o status do lote conforme a etapa escolhida.
- Registro de ocorrências vinculadas a um lote, com tipo, prioridade e descrição.

### Perfil Gestor responsável

- Painel com total de lotes, lotes em andamento, destinações concluídas e ocorrências abertas.
- Gráfico de lotes e movimentações dos últimos seis meses.
- Distribuição dos lotes por grupo de resíduo (A a E).
- Cadastro de lote com geração do QR Code e impressão da etiqueta em PDF.
- Atualização do status do lote e da ocorrência, sempre registrada no histórico.

### Recursos comuns

- Consulta de lotes com busca e filtros por status e grupo.
- Histórico completo de movimentações com busca e linha do tempo por lote.
- Central de IA local: assistente por palavras-chave, análise de inconsistências, resumo gerencial e relatório operacional, tudo calculado no próprio dispositivo, sem utilização de API paga.
- Exportação dos dados em PDF.
- Cópia dos resultados e compartilhamento em `.txt`.
- Persistência local: os registros continuam salvos mesmo após o fechamento do aplicativo.
- Estados de carregamento, erro, tentativa novamente, restauração dos dados de demonstração e lista vazia nas listagens.
- Layout responsivo: barra lateral fixa no computador e tablet e menu em gaveta no celular.

---

## Tecnologias

| Tecnologia | Uso no projeto |
|---|---|
| Flutter 3.27+ e Dart 3.5+ | Interface e lógica do aplicativo para Android, iOS, Web e Windows |
| `provider` | Gerenciamento de estado com `ChangeNotifier` |
| `shared_preferences` | Persistência local dos registros, equivalente ao `localStorage` da versão web |
| `intl` + `flutter_localizations` | Formatação de datas e números em pt-BR |
| `qr_flutter` | Geração do QR Code de cada lote |
| `mobile_scanner` | Leitura do QR Code pela câmera |
| `pdf` + `printing` | Geração de relatórios em PDF e etiquetas dos lotes |
| `share_plus` | Salvamento e compartilhamento dos relatórios em `.txt` |
| DM Sans e Manrope | Tipografia utilizada no aplicativo, incluída nos assets para funcionamento offline |

---

## Arquitetura e organização

O código é separado em três camadas principais:

- **Data:** responsável pelos modelos, dados e persistência.
- **Logic:** concentra as regras de negócio e o gerenciamento do estado.
- **UI:** contém telas, diálogos e widgets reutilizáveis.

As telas não acessam diretamente o armazenamento. Elas leem e alteram o estado por meio dos controladores disponibilizados com `provider`.

### Estrutura principal

```text
lib/
├── main.dart                     # Inicializa datas pt-BR e sobe o app
├── app.dart                      # MultiProvider, tema e RootGate
│                                 # (carregamento, erro, login e app)
├── core/
│   ├── constants/                # Grupos de resíduo, status,
│   │                             # prioridades e etapas
│   ├── theme/                    # Cores, tipografia e decoração
│   └── utils/                    # Formatação de datas/números
│                                 # e breakpoints responsivos
│
├── data/
│   ├── models/                   # WasteLot, Movement, Occurrence,
│   │                             # AppUser e EcoTrackData
│   ├── repositories/             # EcoTrackRepository
│   │                             # (SharedPreferences)
│   ├── seed/                     # Dados de demonstração
│   └── services/                 # AuthService
│                                 # (login de demonstração)
│
├── logic/
│   ├── auth_controller.dart      # Sessão do usuário
│   ├── ecotrack_controller.dart  # Lotes, movimentações e ocorrências
│   ├── navigation_controller.dart# Página atual do menu
│   ├── local_assistant.dart      # Regras da Central de IA local
│   └── app_page.dart             # Páginas e textos do cabeçalho
│
├── services/
│   ├── pdf_export_service.dart   # Relatório em PDF e etiqueta com QR Code
│   └── text_file_service.dart    # Copiar e salvar arquivos .txt
│
└── ui/
    ├── dialogs/                  # Modais de lote, movimentação e ocorrência
    ├── screens/                  # Login, shell, home, dashboard,
    │                             # lots, movements, occurrences,
    │                             # scan, ai e startup
    └── widgets/                  # Botões, painéis, tabelas, pílulas,
                                  # grades, toast e outros componentes

test/
├── local_assistant_test.dart     # Regras do assistente
├── ecotrack_controller_test.dart # Cadastro, movimentação,
│                                 # ocorrências e persistência
└── widget_test.dart              # Login, autenticação e leitura
                                  # do código QR
```

### Decisões de implementação

O `EcoTrackController` atualiza a tela imediatamente e desfaz a alteração caso a gravação falhe.

O formato JSON utilizado para armazenamento local é compatível com a versão web, utilizando a chave:

```text
ecotrack_rss_v1
```

O assistente local é implementado como uma classe Dart independente, sem dependência direta de Flutter, permitindo que suas regras sejam testadas isoladamente.

---

## Como executar

### Requisitos

- Flutter 3.27 ou superior, incluindo o Dart.
- Google Chrome para execução da versão Web.
- Para Android: Android Studio com um emulador ou um celular com depuração USB ativada.
- Para iOS: ambiente compatível com desenvolvimento iOS.

Para verificar a versão instalada do Flutter:

```bash
flutter --version
```

### Passo a passo

#### 1. Clonar o repositório

```bash
git clone https://github.com/gbiel07/ecotrackrss1.git
```

#### 2. Entrar na pasta do projeto

```bash
cd ecotrackrss1
```

#### 3. Instalar as dependências

```bash
flutter pub get
```

#### 4. Executar a análise estática

```bash
flutter analyze
```

O projeto deve apresentar:

```text
No issues found!
```

#### 5. Executar no Google Chrome

```bash
flutter run -d chrome
```

Para executar em um emulador ou dispositivo conectado:

```bash
flutter run
```

### Execução Web

A versão Web pode ser executada pelo Google Chrome utilizando:

```bash
flutter run -d chrome
```

A leitura de QR Code pela câmera pode ser utilizada em ambientes compatíveis, como `localhost` ou HTTPS. No Windows, a busca manual pelo código do lote também está disponível.

---

## Credenciais de demonstração

O aplicativo possui usuários de demonstração para facilitar a avaliação das funcionalidades.

| Perfil | Usuário | Senha |
|---|---|---|
| Funcionário | `funcionario` | `1234` |
| Gestor responsável | `gestor` | `1234` |

Selecione o perfil correspondente no campo **Perfil de acesso** antes de entrar.

---

## Testes e análise estática

Para executar a análise estática:

```bash
flutter analyze
```

Para executar os testes automatizados:

```bash
flutter test
```

Os testes abrangem:

- Regras da Central de IA local.
- Cadastro de lotes com código sequencial.
- Mudança de status ao confirmar uma movimentação.
- Resolução de ocorrências.
- Persistência dos dados entre sessões.
- Autenticação.
- Tela de login.
- Leitura e utilização do código QR.

### Resultado da análise estática

O projeto foi validado com:

```bash
flutter analyze
```

e apresenta:

```text
No issues found!
```

---

## Gerar o APK

Para gerar uma versão de produção para Android:

```bash
flutter build apk --release
```

O arquivo gerado ficará em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

O APK pode ser utilizado como evidência do aplicativo publicado em um release do GitHub.

---

## Telas do aplicativo

As capturas de tela podem ser armazenadas no diretório:

```text
docs/screenshots/
```

Utilize os seguintes nomes:

```text
docs/screenshots/
├── 01-login.png
├── 02-dashboard.png
├── 03-home.png
├── 04-lote.png
├── 05-scanner.png
├── 06-ia.png
├── 07-ocorrencias.png
└── 08-mobile.png
```

### Telas previstas

| Tela | Arquivo |
|---|---|
| Login | `01-login.png` |
| Dashboard do gestor | `02-dashboard.png` |
| Tela inicial do funcionário | `03-home.png` |
| Detalhes do lote com QR Code | `04-lote.png` |
| Leitura de QR Code | `05-scanner.png` |
| Central de IA | `06-ia.png` |
| Ocorrências | `07-ocorrencias.png` |
| Versão para celular | `08-mobile.png` |

Quando as imagens estiverem disponíveis, elas podem ser exibidas no README com:

```markdown
![Login](docs/screenshots/01-login.png)
```

---

## Da versão web para o Flutter

O EcoTrack RSS foi originalmente desenvolvido como um protótipo Web utilizando HTML, CSS e JavaScript.

A versão Flutter foi desenvolvida com o objetivo de migrar a solução para uma arquitetura baseada em Dart e Flutter, mantendo a proposta funcional original.

A migração preserva:

- Estrutura geral das funcionalidades.
- Fluxo de autenticação de demonstração.
- Dados de demonstração.
- Conceito de rastreabilidade dos resíduos.
- Cadastro e acompanhamento de lotes.
- Registro de movimentações.
- Registro e acompanhamento de ocorrências.
- Dashboard gerencial.
- Central de IA local.
- Persistência local dos dados.

A principal diferença está na tecnologia utilizada e na organização interna do código, que passou a utilizar uma arquitetura separada em dados, lógica e interface.

---

## Dados, privacidade e limitações

Os registros ficam armazenados apenas no dispositivo ou navegador em uso, sem sincronização entre aparelhos.

A desinstalação do aplicativo ou a limpeza dos dados do navegador pode apagar os registros armazenados localmente.

A tela de erro oferece a possibilidade de restaurar os dados de demonstração.

O login utilizado nesta versão é exclusivamente de demonstração e não deve ser utilizado para proteger dados reais.

Para uma operação com múltiplos usuários e dados reais, seria necessária a implementação de:

- Banco de dados remoto.
- Autenticação no servidor.
- Controle de permissões.
- Sincronização entre dispositivos.
- Políticas de segurança e backup.
- Infraestrutura de hospedagem.

### Central de IA local

A Central de IA não utiliza um modelo generativo ou uma API externa.

Ela identifica palavras-chave e aplica regras programadas sobre os dados disponíveis localmente.

Por esse motivo, não possui a mesma flexibilidade de interpretação de uma IA generativa online.

As verificações realizadas são **indicativas** e não certificam conformidade legal com a **RDC ANVISA nº 222/2018**. Os resultados devem ser revisados pelo responsável técnico.

---

## Integrantes

- Gabriel Luiz Vicente Soares
- Vitor Souza Pereira
- Vitor Hugo Felix Teixeira
- Vinicius Freitas da Silva

---

## Licença e finalidade

O EcoTrack RSS foi desenvolvido como projeto acadêmico e demonstração de uma solução de rastreabilidade e gerenciamento de resíduos de serviços de saúde.

O sistema apresentado possui caráter demonstrativo e não substitui sistemas certificados, processos internos ou orientações de profissionais responsáveis pela gestão de resíduos de serviços de saúde.
