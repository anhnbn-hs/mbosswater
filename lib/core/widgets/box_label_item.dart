import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class BoxLabelItem extends StatelessWidget {
  final String label, fieldValue;
  IconData? icon;

  BoxLabelItem({
    super.key,
    required this.label,
    required this.fieldValue,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return buildBoxItem(
      label: label,
      fieldValue: fieldValue,
      icon: icon,
    );
  }

  Widget buildBoxItem({
    required String label,
    required String fieldValue,
    IconData? icon,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: AppStyle.boxFieldLabel,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fieldValue,
                  style: AppStyle.boxField.copyWith(color: Colors.black87),
                  maxLines: 10,
                ),
              ),
              icon != null
                  ? Icon(
                      icon,
                      size: 20,
                      color: Colors.black87,
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ],
    );
  }
}
