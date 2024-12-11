import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class BoxSelectNumber extends StatelessWidget {
  const BoxSelectNumber({
    super.key,
    required this.numberNotifier,
    required this.hint,
  });

  final String hint;
  final ValueNotifier<int?> numberNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: numberNotifier,
      builder: (context, value, child) {
        return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffBDBDBD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            tooltip: "Chọn số lượng",
            splashRadius: 8,
            color: Colors.white,
            elevation: 1,
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                AppStyle.boxField.copyWith(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            onSelected: (value) {
              numberNotifier.value = int.parse(value);
            },
            itemBuilder: (BuildContext context) {
              return List.generate(10, (index) => (index++ + 1).toString())
                  .map((value) {
                return PopupMenuItem<String>(
                  value: value,
                  height: 40,
                  child: Text(
                    value,
                    style: AppStyle.boxField.copyWith(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value == null ? hint : value.toString(),
                      style: AppStyle.boxField.copyWith(
                        color: value == null ? Colors.grey : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
