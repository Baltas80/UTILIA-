import 'package:flutter/material.dart';

/// Teclado numérico grande para introducir valores cómodamente en móvil.
/// La integración con cada calculadora se hará en la siguiente actualización conjunta.
class UtiliaNumericKeypad extends StatelessWidget {
  const UtiliaNumericKeypad({
    super.key,
    required this.onKey,
    required this.onBackspace,
    required this.onClear,
    required this.onDone,
    this.showDecimal = true,
    this.showDoubleZero = true,
    this.showSlash = false,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final bool showDecimal;
  final bool showDoubleZero;
  final bool showSlash;

  @override
  Widget build(BuildContext context) {
    final keys = <String>[
      '7',
      '8',
      '9',
      '4',
      '5',
      '6',
      '1',
      '2',
      '3',
      if (showDoubleZero) '00' else '⌫',
      '0',
      if (showDecimal) ',' else if (showSlash) '/',
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'C',
                    onPressed: onClear,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.backspace_outlined,
                    onPressed: onBackspace,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var row = 0; row < 4; row++) ...[
              Row(
                children: [
                  for (var column = 0; column < 3; column++) ...[
                    Expanded(
                      child: _NumberButton(
                        label: keys[row * 3 + column],
                        onPressed: () => onKey(keys[row * 3 + column]),
                      ),
                    ),
                    if (column < 2) const SizedBox(width: 8),
                  ],
                ],
              ),
              if (row < 3) const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.label,
    this.icon,
    required this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(
          label ?? '',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
