import 'package:flutter/material.dart';
import 'dart:math';

class StartSearchingPrompt extends StatefulWidget {
  final Color color1, color2;

  const StartSearchingPrompt(this.color1, this.color2, {super.key});

  @override
  State<StartSearchingPrompt> createState() => _StartSearchingPromptState();
}

class _StartSearchingPromptState extends State<StartSearchingPrompt> with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<Color?> colorAnim1;
  late Animation<Color?> colorAnim2;
  late Animation<double> glowAnim;
  late Animation<double> bounceAnim;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    var curvedAnim = CurvedAnimation(parent: animController, curve: Curves.easeInOut);

    colorAnim1 = ColorTween(begin: widget.color1, end: widget.color2).animate(curvedAnim);
    colorAnim2 = ColorTween(begin: widget.color2, end: widget.color1).animate(curvedAnim);

    glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(curvedAnim);
    bounceAnim = Tween<double>(begin: 0, end: 10).animate(curvedAnim);
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
              Transform.translate(
                offset: Offset(0, sin(bounceAnim.value) * 2),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [colorAnim1.value!, colorAnim2.value!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.search,
                    size: 100,
                    color: Colors.white.withOpacity(glowAnim.value),
                  )
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
                  "Type to start searching...",
                  style: TextStyle(
                    fontSize: 18,
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

  Widget fadeInText(String text) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [colorAnim1.value!, colorAnim2.value!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(glowAnim.value),
        )
      )
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}
