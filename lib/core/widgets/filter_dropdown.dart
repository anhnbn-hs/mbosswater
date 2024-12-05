import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  String selected = "";
  @override
  void initState() {
    super.initState();
    selected = widget.selectedValue;
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          color: Colors.white,
          initialValue: widget.selectedValue,
          onSelected: (value) {
            widget.onChanged(value);
            setState(() {
              selected = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return widget.options.map((value) {
              return PopupMenuItem<String>(
                value: value,
                height: 36,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: "BeVietnam",
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xffEFEFF0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                 selected,
                  style: const TextStyle(
                    fontFamily: "BeVietnam",
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 30),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffEFEFF0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<String>(
        value: widget.selectedValue,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.black,
        ),
        underline: const SizedBox.shrink(),
        // Xóa gạch chân mặc định
        items: widget.options
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontFamily: "BeVietnam",
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        onChanged: widget.onChanged,
        dropdownColor: Colors.white,
        // Màu nền dropdown
        isExpanded: false,
        style: const TextStyle(
          fontFamily: "BeVietnam",
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
}
