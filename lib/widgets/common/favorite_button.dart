import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.isFavorite, required this.onPressed, this.size = 24});

  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
    isSelected: isFavorite,
    icon: AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Icon(
        isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        key: ValueKey(isFavorite),
        size: size,
        color: isFavorite ? AppColors.amber : AppColors.placeholder,
      ),
    ),
  );
}
