import 'package:flutter/material.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';

class FilterDropdownAgency extends StatefulWidget {
  final List<Agency> options;
  final ValueChanged<Agency?> onChanged;

  const FilterDropdownAgency({
    Key? key,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<FilterDropdownAgency> createState() => _FilterDropdownAgencyState();
}

class _FilterDropdownAgencyState extends State<FilterDropdownAgency> {
  Agency? selected;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Agency>(
      color: Colors.white,
      onSelected: (value) {
        widget.onChanged(value);
        setState(() {
          selected = value;
        });
      },
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) {
        return widget.options.map((value) {
          final isSelected = value == selected; // Kiểm tra mục được chọn
          return PopupMenuItem<Agency>(
            value: value,
            height: 40,
            padding: EdgeInsets.zero, // Loại bỏ padding mặc định của PopupMenuItem
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[300] : Colors.white,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                value.name,
                style: const TextStyle(
                  fontFamily: "BeVietnam",
                  overflow: TextOverflow.ellipsis,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        height: 29,
        width: MediaQuery.of(context).size.width / 2 - 24 - 3,
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
                selected?.name ?? "Đại lý",
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: "BeVietnam",
                  color: Colors.black,
                  fontSize: 14,
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