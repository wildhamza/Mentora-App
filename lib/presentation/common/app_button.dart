import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconRight;
  
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(isDisabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(isDisabled);
      case ButtonType.outline:
        return _buildOutlinedButton(isDisabled);
      case ButtonType.text:
        return _buildTextButton(isDisabled);
    }
  }
  
  Widget _buildElevatedButton(bool isDisabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }
  
  Widget _buildSecondaryButton(bool isDisabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.secondary.withOpacity(0.6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }
  
  Widget _buildOutlinedButton(bool isDisabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDisabled ? AppColors.primary.withOpacity(0.6) : AppColors.primary,
          ),
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _buildButtonContent(AppColors.primary),
      ),
    );
  }
  
  Widget _buildTextButton(bool isDisabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: _buildButtonContent(AppColors.primary),
      ),
    );
  }
  
  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    
    if (icon == null) {
      return Text(text);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!iconRight) Icon(icon, size: 18, color: color),
        if (!iconRight) const SizedBox(width: 8),
        Text(text),
        if (iconRight) const SizedBox(width: 8),
        if (iconRight) Icon(icon, size: 18, color: color),
      ],
    );
  }
}
