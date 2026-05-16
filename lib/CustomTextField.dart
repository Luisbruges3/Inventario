import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController? cnt;
  final bool isPassword;
  final TextInputType typeKeyboard;

  const CustomTextField(
    {
      super.key,
      required this.placeholder,
      this.cnt,
      this.isPassword = false,
      this.typeKeyboard = TextInputType.text
    });
  

    @override
    Widget build(BuildContext context) {
    return TextField(
      controller:cnt, 
      obscureText:isPassword, 
      keyboardType:typeKeyboard,
      decoration: InputDecoration(
        labelText: placeholder,
        border: OutlineInputBorder()
        )
      );
}

}