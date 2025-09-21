import 'package:flutter/material.dart';

class SmallField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const SmallField({Key? key, required this.label, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class SmallFieldFlexible extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const SmallFieldFlexible({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
