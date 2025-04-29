import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = backgroundColor ?? theme.primaryColor;
    final baseTextColor = textColor ?? Colors.white;
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColor,
          foregroundColor: baseTextColor,
          padding: padding ?? const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMedium,
            horizontal: AppTheme.spacingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          disabledBackgroundColor: baseColor.withOpacity(0.6),
          disabledForegroundColor: baseTextColor.withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: baseTextColor,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: baseTextColor,
                    ),
                  ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseBorderColor = borderColor ?? theme.primaryColor;
    final baseTextColor = textColor ?? theme.primaryColor;
    
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: baseBorderColor),
          foregroundColor: baseTextColor,
          padding: padding ?? const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMedium,
            horizontal: AppTheme.spacingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: baseTextColor,
                  strokeWidth: 2,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: baseTextColor,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: baseTextColor,
                    ),
                  ),
      ),
    );
  }
}

class TextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final Color? textColor;
  final IconData? icon;
  final double? fontSize;

  const TextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.textColor,
    this.icon,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextColor = textColor ?? theme.primaryColor;
    
    return InkWell(
      onTap: isDisabled ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingSmall,
          horizontal: AppTheme.spacingSmall,
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isDisabled ? baseTextColor.withOpacity(0.6) : baseTextColor,
                  ),
                  const SizedBox(width: AppTheme.spacingXSmall),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? AppTheme.fontSizeSmall,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? baseTextColor.withOpacity(0.6) : baseTextColor,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? AppTheme.fontSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? baseTextColor.withOpacity(0.6) : baseTextColor,
                ),
              ),
      ),
    );
  }
}
