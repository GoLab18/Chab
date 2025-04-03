import 'package:flutter/material.dart';

class SearchResultsNotFound extends StatefulWidget {
  final Color color1, color2;

  const SearchResultsNotFound(this.color1, this.color2, {super.key});

  @override
  State<SearchResultsNotFound> createState() => _SearchResultsNotFoundState();
}

class _SearchResultsNotFoundState extends State<SearchResultsNotFound> with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<Color?> colorAnim1;
  late Animation<Color?> colorAnim2;

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
              gradientIcon(),

              const SizedBox(height: 10),

              gradientText("No Results Found"),
            ]
          )
        );
      }
    );
  }

  Widget gradientIcon() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [colorAnim1.value!, colorAnim2.value!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: const Icon(
        Icons.search_off,
        size: 100,
        color: Colors.white
      )
    );
  }

  Widget gradientText(String text) {
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
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white
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
