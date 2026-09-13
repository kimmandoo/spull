import 'package:flutter/material.dart';

class PixelColors {
  // Warm pixel-cat palette: espresso outline, tangerine fur, cream, and pink.
  static const ink = Color(0xFF4B2418);
  static const background = Color(0xFFFFE9C7);
  static const panel = Color(0xFFFFFBF3);
  static const panelLight = Color(0xFFFFF3DD);
  static const outline = Color(0xFFE7B98F);
  static const cream = Color(0xFFFFF0D0);
  static const text = Color(0xFF4B2418);
  static const muted = Color(0xFF8A6652);
  static const orange = Color(0xFFFF9D3A);
  static const yellow = Color(0xFFFF9A83);
  static const mint = Color(0xFFD86420);
  static const pink = Color(0xFFF07B77);
  static const sky = Color(0xFFFFC875);
  static const logoOrange = Color(0xFFFF9D3A);
  static const logoMint = Color(0xFFFFF0D0);
  static const logoPink = Color(0xFFF07B77);
}

class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = PixelColors.panel,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PixelColors.outline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A172033),
            offset: Offset(0, 5),
            blurRadius: 18,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = PixelButtonTone.ghost,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PixelButtonTone tone;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final baseBackground = switch (tone) {
      PixelButtonTone.primary => PixelColors.orange,
      PixelButtonTone.danger => PixelColors.pink,
      PixelButtonTone.ghost => PixelColors.panel,
    };
    final background = enabled ? baseBackground : PixelColors.panelLight;
    final foreground = enabled
        ? (tone == PixelButtonTone.ghost ? PixelColors.text : PixelColors.ink)
        : PixelColors.muted;
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled && tone != PixelButtonTone.ghost
                ? baseBackground
                : PixelColors.outline,
          ),
        ),
        child: expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

enum PixelButtonTone { primary, danger, ghost }

class PixelTag extends StatelessWidget {
  const PixelTag({
    super.key,
    required this.label,
    this.color = PixelColors.mint,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PixelLogo extends StatelessWidget {
  const PixelLogo({super.key, this.size = 58});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SpullLogoPainter()),
    );
  }
}

class _SpullLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32;
    canvas
      ..save()
      ..scale(scale);
    final outline = Paint()
      ..color = PixelColors.text
      ..isAntiAlias = false;
    final fur = Paint()
      ..color = PixelColors.orange
      ..isAntiAlias = false;
    final darkFur = Paint()
      ..color = PixelColors.yellow
      ..isAntiAlias = false;
    final cream = Paint()
      ..color = PixelColors.cream
      ..isAntiAlias = false;
    final pink = Paint()
      ..color = PixelColors.pink
      ..isAntiAlias = false;

    void rect(Paint paint, double x, double y, double width, double height) {
      canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
    }

    final head = Path()
      ..moveTo(4, 9)
      ..lineTo(4, 5)
      ..lineTo(6, 5)
      ..lineTo(6, 3)
      ..lineTo(10, 3)
      ..lineTo(10, 5)
      ..lineTo(12, 5)
      ..lineTo(12, 7)
      ..lineTo(20, 7)
      ..lineTo(20, 5)
      ..lineTo(22, 5)
      ..lineTo(22, 3)
      ..lineTo(26, 3)
      ..lineTo(26, 5)
      ..lineTo(28, 5)
      ..lineTo(28, 9)
      ..lineTo(30, 9)
      ..lineTo(30, 11)
      ..lineTo(31, 11)
      ..lineTo(31, 24)
      ..lineTo(29, 24)
      ..lineTo(29, 27)
      ..lineTo(26, 27)
      ..lineTo(26, 29)
      ..lineTo(23, 29)
      ..lineTo(23, 30)
      ..lineTo(9, 30)
      ..lineTo(9, 29)
      ..lineTo(6, 29)
      ..lineTo(6, 27)
      ..lineTo(4, 27)
      ..lineTo(4, 24)
      ..lineTo(2, 24)
      ..lineTo(2, 11)
      ..lineTo(4, 11)
      ..close();
    canvas.drawPath(head, outline);

    final face = Path()
      ..moveTo(5, 11)
      ..lineTo(8, 11)
      ..lineTo(8, 8)
      ..lineTo(11, 8)
      ..lineTo(11, 10)
      ..lineTo(21, 10)
      ..lineTo(21, 8)
      ..lineTo(24, 8)
      ..lineTo(24, 11)
      ..lineTo(27, 11)
      ..lineTo(27, 14)
      ..lineTo(29, 14)
      ..lineTo(29, 23)
      ..lineTo(27, 23)
      ..lineTo(27, 26)
      ..lineTo(7, 26)
      ..lineTo(7, 23)
      ..lineTo(4, 23)
      ..lineTo(4, 14)
      ..lineTo(5, 14)
      ..close();
    canvas.drawPath(face, fur);

    rect(cream, 6, 7, 2, 4);
    rect(cream, 8, 8, 2, 3);
    rect(cream, 24, 7, 2, 4);
    rect(cream, 22, 8, 2, 3);
    rect(pink, 7, 9, 1, 2);
    rect(pink, 24, 9, 1, 2);
    rect(darkFur, 14, 10, 4, 2);
    rect(darkFur, 15, 12, 2, 2);
    rect(darkFur, 4, 15, 4, 2);
    rect(darkFur, 24, 15, 5, 2);
    rect(darkFur, 4, 20, 3, 2);
    rect(darkFur, 25, 20, 4, 2);
    rect(darkFur, 7, 24, 3, 2);
    rect(darkFur, 22, 24, 3, 2);

    rect(outline, 8, 14, 4, 5);
    rect(outline, 20, 14, 4, 5);
    rect(cream, 9, 14, 1, 1);
    rect(cream, 21, 14, 1, 1);
    rect(cream, 8, 19, 4, 1);
    rect(cream, 20, 19, 4, 1);
    rect(cream, 10, 18, 12, 2);
    rect(cream, 8, 20, 16, 6);
    rect(cream, 10, 26, 12, 2);

    rect(pink, 15, 17, 2, 2);
    final openMouth = Path()
      ..moveTo(12, 20)
      ..lineTo(20, 20)
      ..lineTo(20, 21)
      ..lineTo(22, 21)
      ..lineTo(22, 26)
      ..lineTo(20, 26)
      ..lineTo(20, 28)
      ..lineTo(12, 28)
      ..lineTo(12, 26)
      ..lineTo(10, 26)
      ..lineTo(10, 21)
      ..lineTo(12, 21)
      ..close();
    canvas.drawPath(openMouth, outline);
    rect(cream, 12, 20, 3, 2);
    rect(cream, 17, 20, 3, 2);
    rect(pink, 13, 24, 6, 4);
    rect(pink, 15, 23, 2, 1);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PixelProgressBar extends StatelessWidget {
  const PixelProgressBar({super.key, required this.value, this.height = 10});

  final double? value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: value == null
            ? const LinearProgressIndicator(
                backgroundColor: PixelColors.outline,
                valueColor: AlwaysStoppedAnimation<Color>(PixelColors.mint),
              )
            : LinearProgressIndicator(
                value: value!.clamp(0, 1),
                backgroundColor: PixelColors.outline,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  PixelColors.mint,
                ),
              ),
      ),
    );
  }
}
