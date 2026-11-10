import 'package:colportando_app/features/auth/domain/entities/current_account.dart';
import 'package:colportando_app/features/auth/presentation/pages/account_page.dart';
import 'package:colportando_app/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('no desborda en un teléfono estrecho con texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const account = CurrentAccount(
      accountId: '5f106e23-9e50-422f-aa85-f4927eae9628',
      email: 'proyectos_ids@ulv.edu.mx',
      status: 'ACTIVE',
      sessionId: '57000040-0b05-4064-a660-000000000000',
    );
    const state = AuthState(
      status: AuthStatus.authenticated,
      account: account,
      message: 'La sesión está vigente y protegida.',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: AccountPage(account: account, state: state),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Identidad y sesión'), findsOneWidget);
  });
}
