import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class BoxSelectNumber extends StatelessWidget {
  const BoxSelectNumber({
    super.key,
    required this.numberNotifier,
    required this.hint,
  });

  final String hint;
  final ValueNotifier<int> numberNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: numberNotifier,
      builder: (context, value, child) {
        return Container(
          height: 38,
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
              textStyle: WidgetStatePropertyAll(AppStyle.boxField),
            ),
            onSelected: (value) {
              numberNotifier.value = int.parse(value);
            },
            itemBuilder: (BuildContext context) {
              return List.generate(10, (index) =>(index++ + 1).toString()).map((value) {
                return PopupMenuItem<String>(
                  value: value,
                  height: 38,
                  child: Text(
                    value,
                    style: AppStyle.boxField,
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
                    child: Text(value.toString()),
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