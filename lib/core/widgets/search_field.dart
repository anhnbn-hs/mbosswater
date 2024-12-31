import 'dart:async';

import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final Function(String) onSearch;
  final String hint;
  final TextEditingController controller;

  const SearchField({
    super.key,
    required this.onSearch,
    required this.hint,
    required this.controller,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  bool hasValue = false;

  void _onSearchChanged(String query) {
    // Hủy Timer cũ nếu có
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    // Tạo Timer mới
    _debounce = Timer(const Duration(milliseconds: 800), () {
      widget.onSearch(query);
    });
  }

  @override
  void dispose() {
    // Hủy Timer khi Widget bị dispose
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) {
        _onSearchChanged(value);
        if (widget.controller.text != "") {
          setState(() {
            hasValue = true;
          });
        } else {
          setState(() {
            hasValue = false;
          });
        }
      },
      onTapOutside: (event) => FocusScope.of(context).requestFocus(FocusNode()),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'BeVietNam',
        color: Color(0xff3C3C43),
      ),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(borderSide: BorderSide.none),
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontFamily: 'BeVietNam',
          color: Colors.grey.shade500,
        ),
        suffixIcon: hasValue
            ? IconButton(
          onPressed: () {
            setState(() {
              widget.controller.clear();
              _onSearchChanged("");
              hasValue = false;
            });
          },
          icon: const Icon(
            Icons.clear,
            color: Colors.grey,
            size: 18,
          ),
        )
            : null,
        isCollapsed: true,
      ),
      cursorColor: Colors.grey,
    );
  }
}