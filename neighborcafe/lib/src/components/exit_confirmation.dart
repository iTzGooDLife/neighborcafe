import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;
  final bool Function()? isDrawerOpen;

  const ExitConfirmationWrapper(
      {super.key, required this.child, this.isDrawerOpen});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (isDrawerOpen != null && isDrawerOpen!()) {
          // If the drawer is open, just close it
          Navigator.of(context).pop();
        } else {
          final bool shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: child,
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Deseas salir de la aplicación?'),
            content: const Text('Presiona Confirmar para salir.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
