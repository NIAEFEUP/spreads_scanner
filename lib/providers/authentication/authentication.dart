import 'package:flutter/widgets.dart';
import 'package:jantar_de_curso_scanner/providers/authentication/notifier.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider extends StatelessWidget {
  const AuthenticationProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthenticationNotifier(),
      child: child,
    );
  }
}
