import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSearch,
  });

  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onSearch;

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late bool isEmpty;

  @override
  void initState() {
    super.initState();
    isEmpty = widget.controller.text.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(200, 168, 201, 0.3),
              blurRadius: 20,
              offset: Offset(0, 10)),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        onChanged: _onChange,
        onFieldSubmitted: widget.onSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'search'.tr,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isEmpty
              ? const Icon(Icons.search)
              : GestureDetector(
                  onTap: _clear,
                  child: const Icon(Icons.clear),
                ),
        ),
      ),
    );
  }

  void _clear() {
    setState(() {
      isEmpty = true;
    });
    widget.controller.text = '';
  }

  void _onChange(String text) {
    setState(() {
      isEmpty = text.isEmpty;
    });
    widget.onChanged?.call(text);
  }
}
