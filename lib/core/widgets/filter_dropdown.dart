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
    return PopupMenuButton<String>(
      color: Colors.white,
      initialValue: widget.selectedValue,
      onSelected: (value) {
        widget.onChanged(value);
        setState(() {
          selected = value;
        });
      },
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) {
        return widget.options.map((value) {
          return PopupMenuItem<String>(
            value: value,
            height: 40,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: "BeVietnam",
                overflow: TextOverflow.ellipsis,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        height: 29,
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xffEFEFF0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
               selected,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: "BeVietnam",
                  color: Colors.black,
                  height: 1.4,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
