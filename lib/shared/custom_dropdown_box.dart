// ignore_for_file: use_key_in_widget_constructors

import 'package:carive/shared/constants.dart';
import 'package:flutter/material.dart';

class CustomDropdownBox extends StatelessWidget {
  final String title;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropdownBox({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: themeColorblueGrey,
            fontSize: 18,
          ),
        ),
        hSizedBox10,
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: themeColorGreen),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => value == null ? "Field required" : null,
              borderRadius: BorderRadius.circular(20),
              isExpanded: true,
              icon: const Visibility(
                visible: false,
                child: Icon(Icons.arrow_downward),
              ),
              dropdownColor: themeColorGrey,
              style: const TextStyle(color: Colors.white),
              value: value,
              items: items.map((e) {
                return DropdownMenuItem<String?>(
                  value: e,
                  child: Center(child: Text(e)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        hSizedBox20
      ],
    );
  }
}
