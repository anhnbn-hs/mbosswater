import 'package:flutter/material.dart';

class WaterQualityRating extends StatelessWidget {
  const WaterQualityRating({
    super.key,
    required this.selectedNumber,
  });

  final ValueNotifier<int> selectedNumber;

  @override
  Widget build(BuildContext context) {
    final List<Color> activeColor = [
      const Color(0xffFF4D4F), // Đỏ (mức 1 - thấp nhất)
      const Color(0xffFF7A45), // Cam nhạt (mức 2)
      const Color(0xffFFC53D), // Vàng (mức 3 - trung bình)
      const Color(0xff73D13D), // Xanh lá nhạt (mức 4)
      const Color(0xff52C41A), // Xanh lá đậm (mức 5 - cao nhất)
    ];
    return ValueListenableBuilder(
      valueListenable: selectedNumber,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [1, 2, 3, 4, 5].map(
            (e) {
              bool isActive = value == e;
              return GestureDetector(
                onTap: () => selectedNumber.value = e,
                child: Container(
                  height: 27,
                  width: 27,
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor[selectedNumber.value - 1]
                        : Colors.white,
                    border: isActive
                        ? null
                        : Border.all(color: const Color(0xffD3DCE6)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      e.toString(),
                      style: TextStyle(
                        fontFamily: "BeVietnam",
                        color:
                            isActive ? Colors.white : const Color(0xffD3DCE6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
