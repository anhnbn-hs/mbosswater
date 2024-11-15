import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class BoxSelectNumber extends StatelessWidget {
  const BoxSelectNumber({
    super.key,
    required this.numberNotifier,
    required this.numberController,
    required this.hint,
  });

  final String hint;
  final ValueNotifier<int> numberNotifier;
  final TextEditingController numberController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: numberNotifier,
      builder: (context, value, child) {
        if (value != 0) numberController.text = value.toString();
        return Container(
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffBDBDBD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton<String>(
            color: Colors.white,
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
                  height: 30,
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
                    child: TextFormField(
                      maxLines: 1,
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      style: AppStyle.boxField.copyWith(height: 2),
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: hint,
                        hintStyle: AppStyle.boxField,
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