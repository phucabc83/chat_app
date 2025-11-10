import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;
  const CustomTextField({
    super.key,
    this.hint = '',
    this.icon = Icons.text_fields,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return     Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hint: Text(hint,style: TextStyle(color: Colors.white70),),
          prefixIcon: Icon(icon,color: Colors.white70,),
          border: InputBorder.none,
        ),
      ),
    );

  }
}
