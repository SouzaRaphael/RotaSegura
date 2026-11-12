import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/place.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class TripFields extends StatelessWidget {
  const TripFields({
    super.key,
    required this.origin,
    required this.destination,
    required this.onPickOrigin,
    required this.onPickDestination,
    required this.onSwap,
    required this.onClear,
  });

  final Place? origin;
  final Place? destination;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;
  final VoidCallback? onSwap;

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: const [BoxShadow(color: Color(0x0F173B6C), blurRadius: 14, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            _TripField(
              label: 'Origem',
              place: origin,
              hint: 'De onde você sai?',
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.blue, width: 3),
                ),
              ),
              onTap: onPickOrigin,
            ),
            const Divider(height: 1, indent: 46, color: AppColors.border),
            _TripField(
              label: 'Destino',
              place: destination,
              hint: 'Para onde você vai?',
              leading: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.destIcon),
              onTap: onPickDestination,
            ),
          ],
        ),
      ),
      Wrap(
        spacing: 12,
        children: [
          _FieldAction(icon: LucideIcons.arrowUpDown, label: 'Trocar origem e destino', onPressed: onSwap),
          _FieldAction(icon: LucideIcons.eraser, label: 'Limpar campos', onPressed: onClear),
        ],
      ),
    ],
  );
}

class _FieldAction extends StatelessWidget {
  const _FieldAction({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 16),
    label: Text(label),
    style: TextButton.styleFrom(
      foregroundColor: AppColors.blue,
      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    ),
  );
}

class _TripField extends StatelessWidget {
  const _TripField({
    required this.label,
    required this.place,
    required this.hint,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final Place? place;
  final String hint;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label: ${place?.name ?? 'não escolhida'}',
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            SizedBox(width: 20, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.small.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    place?.name ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: place == null ? FontWeight.w400 : FontWeight.w700,
                      color: place == null ? AppColors.placeholder : AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.search, size: 17, color: AppColors.placeholder),
          ],
        ),
      ),
    ),
  );
}
