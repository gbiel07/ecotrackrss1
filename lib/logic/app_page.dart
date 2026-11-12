/// Páginas do sistema, com título e subtítulo exibidos no cabeçalho.
enum AppPage {
  home('Tela inicial', 'Resumo das suas atividades e atalhos operacionais.'),
  dashboard('Dashboard', 'Visão geral da operação e dos indicadores de RSS.'),
  scan('Escanear QR Code', 'Leia o código de um lote ou informe o identificador manualmente.'),
  lots('Consultar lotes', 'Pesquise lotes e acompanhe o status de cada resíduo.'),
  newLot('Cadastrar lote', 'Registre um novo lote de resíduos e gere seu QR Code.'),
  movements('Movimentações', 'Acompanhe o histórico de movimentações registradas.'),
  occurrences('Ocorrências', 'Registre e acompanhe situações que precisam de atenção.'),
  ai('Central de inteligência artificial',
      'Assistente local, análise de registros e relatórios sem API paga.');

  const AppPage(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
