import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalKeyboardToolbar extends StatelessWidget {
  final void Function(String text) onInput;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onDismiss;

  const TerminalKeyboardToolbar({
    super.key,
    required this.onInput,
    this.onCopy,
    this.onPaste,
    this.onDismiss,
  });

  void _send(String text) {
    HapticFeedback.lightImpact();
    onInput(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            color: theme.dividerColor,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: [
                _KeyBtn(label: 'Esc', onTap: () => _send('\x1b')),
                const SizedBox(width: 4),
                _KeyBtn(label: 'Tab', onTap: () => _send('\t')),
                const SizedBox(width: 4),
                _KeyBtn(label: 'Ctrl', onTap: () {}),
                const SizedBox(width: 4),
                _KeyBtn(label: '◀', onTap: () => _send('\x1b[D')),
                _KeyBtn(label: '▼', onTap: () => _send('\x1b[B')),
                _KeyBtn(label: '▶', onTap: () => _send('\x1b[C')),
                _KeyBtn(label: '▲', onTap: () => _send('\x1b[A')),
                const SizedBox(width: 4),
                _KeyBtn(label: '✂', onTap: onCopy),
                _KeyBtn(label: '📋', onTap: onPaste),
                const SizedBox(width: 4),
                _KeyBtn(label: 'Home', onTap: () => _send('\x1b[H')),
                _KeyBtn(label: 'End', onTap: () => _send('\x1b[F')),
                const SizedBox(width: 4),
                _KeyBtn(label: 'Pg▲', onTap: () => _send('\x1b[5~')),
                _KeyBtn(label: 'Pg▼', onTap: () => _send('\x1b[6~')),
                if (onDismiss != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _KeyBtn(label: '✕', onTap: onDismiss),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _KeyBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 36),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
