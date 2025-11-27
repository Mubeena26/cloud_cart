import 'package:cloud_cart/core/theme/colors.dart';
import 'package:cloud_cart/core/theme/text_styles.dart';
import 'package:flutter/material.dart';


class CustomElavatedTextButton extends StatelessWidget {
  const CustomElavatedTextButton({
    super.key,
    this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.padverticle,
    this.padhorizondal,
    this.fontSize,
    this.bgcolor,
    this.borderRadius,
    this.textColor,
    this.borderColor,
    this.textStyle,
  });

  final void Function()? onPressed;
  final String text;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? padverticle;
  final double? padhorizondal;
  final Color? bgcolor;
  final double? borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgcolor ?? PColors.primaryColor,
        foregroundColor: textColor ?? PColors.colorFFFFFF,
        padding: EdgeInsets.symmetric(
          vertical: padverticle ?? 8,
          horizontal: padhorizondal ?? 16,
        ),
        fixedSize: Size(width ?? size.width - 40, height ?? 56),
        maximumSize: Size(width ?? size.width - 40, height ?? 56),
        minimumSize: Size(width ?? size.width - 40, height ?? 56),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor ?? PColors.primaryColor),
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textStyle ??
            getTextStyle(
              fontSize: fontSize ?? 16,
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
