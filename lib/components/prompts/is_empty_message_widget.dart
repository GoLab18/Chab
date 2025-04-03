import 'package:flutter/material.dart';

class IsEmptyMessageWidget extends StatefulWidget {
  final Color color1, color2;
  final String text;
  final IconData iconData;

  const IsEmptyMessageWidget(this.color1, this.color2, {
    super.key,
    required this.text,
    required this.iconData
  });

  @override
  State<IsEmptyMessageWidget> createState() => _IsEmptyMessageWidgetState();
}

class _IsEmptyMessageWidgetState extends State<IsEmptyMessageWidget> with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<Color?> colorAnim1;
  late Animation<Color?> colorAnim2;
  late Animation<double> glowAnim;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    var ca = CurvedAnimation(parent: animController, curve: Curves.easeInOut);

    colorAnim1 = ColorTween(begin: widget.color2, end: widget.color1).animate(ca);
    colorAnim2 = ColorTween(begin: widget.color1, end: widget.color2).animate(ca);

    glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(ca);
    scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(ca);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: scaleAnim.value,
                child: Icon(
                  widget.iconData,
                  size: 80,
                  color: widget.color1.withOpacity(glowAnim.value),
                )
              ),

              const SizedBox(height: 10),

              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [colorAnim1.value!, colorAnim2.value!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(glowAnim.value),
                  )
                )
              )
            ]
          )
        );
      }
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}
