import 'package:cloud_cart/core/theme/colors.dart';
import 'package:flutter/material.dart';

class OtpField extends StatelessWidget {
  const OtpField({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> otpDigits = ['8', '4', '0', '0'];
    int activeIndex = 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(otpDigits.length, (index) {
        bool isActive = index == activeIndex;
        bool isFilled = index < activeIndex;
        bool isEmpty = otpDigits[index] == '0' && index > activeIndex;

        Color backgroundColor = isActive
            ? PColors.color0C9C34
            : isFilled
                ? const Color(0xFFE3E4E3)
                : isEmpty
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFE3E4E3);

        Color textColor = isActive
            ? PColors.colorFFFFFF
            : isFilled
                ? PColors.color000000
                : Colors.grey;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4), // improved spacing
          width: 66,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            otpDigits[index],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        );
      }),
    );
  }
}
