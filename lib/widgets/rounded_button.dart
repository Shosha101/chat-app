import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Function onPressed;

  const RoundedButton(
      {required this.height,
      required this.name,
      required this.width,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 94, 218, 1.0),
          borderRadius: BorderRadius.circular(height*0.25)
      ),
      height: height,
      width: width,
      child: TextButton(


          onPressed: ()=>onPressed(),
          child: Text(
            name,
            style: TextStyle(fontSize: 22, height: 1.5,color: Colors.white),

          )),
    );
  }
}
