import 'package:ecotrack_rss/app.dart';
import 'package:ecotrack_rss/data/models/app_user.dart';
import 'package:ecotrack_rss/data/repositories/ecotrack_repository.dart';
import 'package:ecotrack_rss/data/services/auth_service.dart';
import 'package:ecotrack_rss/ui/screens/scan/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService', () {
    const service = AuthService();

    test('aceita credenciais de demonstração com o perfil correto', () {
      final user = service.authenticate(
        username: ' Gestor ',
        password: '1234',
        role: UserRole.manager,
      );
      expect(user?.name, 'Ana Martins');
      expect(user?.initials, 'AM');
    });

    test('recusa perfil diferente do cadastrado', () {
      final user = service.authenticate(
        username: 'funcionario',
        password: '1234',
        role: UserRole.manager,
      );
      expect(user, isNull);
    });
  });

  test('extrai o código do lote de um texto lido pelo QR Code', () {
    expect(extractLotCode('https://exemplo.com/lote?id=RSS-2026-001&x=1'), 'RSS-2026-001');
    expect(extractLotCode('  RSS-2026-004  '), 'RSS-2026-004');
    expect(extractLotCode('OUTRO'), 'OUTRO');
  });

  testWidgets('exibe a tela de login e valida credenciais inválidas', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(EcoTrackApp(repository: EcoTrackRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Credenciais para demonstração'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'gestor');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha-errada');
    await tester.tap(find.text('Entrar  →'));
    await tester.pump();

    expect(find.text('Usuário, senha ou perfil inválido.'), findsOneWidget);
  });
}
