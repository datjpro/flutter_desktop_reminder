import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_enhanced.dart';

class LuxuryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool hasShadow;

  const LuxuryCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.borderRadius,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppThemeEnhanced.spacingMd),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppThemeEnhanced.surfaceLight,
          gradient: gradient,
          borderRadius: borderRadius ?? AppThemeEnhanced.mediumRadius,
          boxShadow: hasShadow ? [AppThemeEnhanced.softShadow] : null,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double opacity;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.opacity = 0.1,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppThemeEnhanced.spacingMd),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: borderRadius ?? AppThemeEnhanced.mediumRadius,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class LuxuryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final double? height;

  const LuxuryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : AppThemeEnhanced.primaryGradient,
        borderRadius: AppThemeEnhanced.mediumRadius,
        border: isOutlined
            ? Border.all(
                color: color ?? AppThemeEnhanced.primaryBlue,
                width: 2,
              )
            : null,
        boxShadow: isOutlined ? null : [AppThemeEnhanced.softShadow],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : Colors.transparent,
          foregroundColor: isOutlined 
              ? (color ?? AppThemeEnhanced.primaryBlue)
              : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppThemeEnhanced.mediumRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeEnhanced.spacingLg,
            vertical: AppThemeEnhanced.spacingMd,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LuxuryTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;

  const LuxuryTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
  });

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppThemeEnhanced.mediumRadius,
          boxShadow: _isFocused ? [AppThemeEnhanced.softShadow] : null,
        ),
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          onTap: widget.onTap,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppThemeEnhanced.primaryBlue)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Icon(widget.suffixIcon, color: AppThemeEnhanced.primaryBlue),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: AppThemeEnhanced.mediumRadius,
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppThemeEnhanced.mediumRadius,
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppThemeEnhanced.mediumRadius,
              borderSide: const BorderSide(
                color: AppThemeEnhanced.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppThemeEnhanced.mediumRadius,
              borderSide: const BorderSide(
                color: AppThemeEnhanced.errorColor,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppThemeEnhanced.mediumRadius,
              borderSide: const BorderSide(
                color: AppThemeEnhanced.errorColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppThemeEnhanced.spacingMd),
          ),
        ),
      ),
    );
  }
}

class LuxuryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final Gradient? gradient;

  const LuxuryAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient ?? AppThemeEnhanced.primaryGradient,
        boxShadow: [AppThemeEnhanced.softShadow],
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? leading ??
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: onBack ?? () => Navigator.pop(context),
                )
            : leading,
        actions: actions,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class LuxuryChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final Color? color;
  final IconData? icon;

  const LuxuryChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spacingMd,
          vertical: AppThemeEnhanced.spacingSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppThemeEnhanced.primaryGradient
              : null,
          color: isSelected
              ? null
              : (color ?? AppThemeEnhanced.primaryBlue.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (color ?? AppThemeEnhanced.primaryBlue.withOpacity(0.3)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (color ?? AppThemeEnhanced.primaryBlue),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (color ?? AppThemeEnhanced.primaryBlue),
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (color ?? AppThemeEnhanced.primaryBlue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LuxuryBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const LuxuryBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemeEnhanced.textPrimary,
              ),
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
          
          // Actions
          if (actions != null)
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}

class LuxuryLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LuxuryLoadingIndicator({
    super.key,
    this.message,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppThemeEnhanced.primaryGradient,
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppThemeEnhanced.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
