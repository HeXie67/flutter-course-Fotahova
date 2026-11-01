import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 16,
  });

  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isLiked),
          size: size,
          color: isLiked ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}