import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Function onPressed;
  // Shows a spinner in place of the label and ignores taps
  final bool isLoading;

  const RoundedButton(
      {super.key,
      required this.height,
      required this.name,
      required this.width,
      required this.onPressed,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: FilledButton(
          onPressed: isLoading ? null : () => onPressed(),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
    );
  }
}
