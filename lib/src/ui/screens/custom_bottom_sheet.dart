import 'package:flutter/material.dart';

Future<dynamic> showCustomBottomSheet(BuildContext context, onPressed, {String? title, String? buttonText}) {
  return showModalBottomSheet(
    context: context,
    enableDrag: true,
    backgroundColor: Colors.amber.shade50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) => Container(
      constraints: BoxConstraints.tight(Size(double.infinity, 200)),
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            title ?? "Oops! Game Over",
            style: TextStyle(fontSize: 25),
          ),
          Spacer(),
          ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: onPressed,
            child: Text(buttonText ?? "Try Again"),
          ),
          Spacer(),
        ],
      ),
    ),
  );
}
