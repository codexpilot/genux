// Example of GuxRadioGroup usage

import 'package:flutter/widgets.dart';
import 'package:genux/genux.dart';

class RadioGroupExample extends StatefulWidget {
  const RadioGroupExample({super.key});

  @override
  State<RadioGroupExample> createState() => _RadioGroupExampleState();
}

class _RadioGroupExampleState extends State<RadioGroupExample> {
  String? selectedSize = 'medium';

  @override
  Widget build(BuildContext context) {
    return GuxRadioGroup<String>(
      value: selectedSize,
      onChanged: (value) {
        setState(() {
          selectedSize = value;
        });
      },
      children: [
        GuxRadio(
          value: 'small',
          groupValue: selectedSize,
          onChanged: (value) {
            setState(() {
              selectedSize = value;
            });
          },
          style: const GuxRadioStyle(
            checkedColor: Color(0xFF3B82F6),
            borderColor: Color(0xFFD1D5DB),
          ),
        ),
        GuxRadio(
          value: 'medium',
          groupValue: selectedSize,
          onChanged: (value) {
            setState(() {
              selectedSize = value;
            });
          },
          style: const GuxRadioStyle(
            checkedColor: Color(0xFF3B82F6),
            borderColor: Color(0xFFD1D5DB),
          ),
        ),
        GuxRadio(
          value: 'large',
          groupValue: selectedSize,
          onChanged: (value) {
            setState(() {
              selectedSize = value;
            });
          },
          style: const GuxRadioStyle(
            checkedColor: Color(0xFF3B82F6),
            borderColor: Color(0xFFD1D5DB),
          ),
        ),
      ],
    );
  }
}
