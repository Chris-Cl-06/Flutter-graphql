import 'package:flutter/material.dart';

class RectangularButton extends StatelessWidget {
  final String texto;
  const RectangularButton(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      height: 90,
      width: 200,
      child: Text(texto),
    );
  }
}
